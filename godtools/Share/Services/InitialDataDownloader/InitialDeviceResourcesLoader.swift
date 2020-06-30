//
//  InitialDeviceResourcesLoader.swift
//  godtools
//
//  Created by Levi Eggert on 6/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class InitialDeviceResourcesLoader {
    
    private let realmDatabase: RealmDatabase
    private let legacyRealmMigration: LegacyRealmMigration
    private let attachmentsFileCache: AttachmentsFileCache
    private let translationsFileCache: TranslationsFileCache
    private let realmResourcesCache: RealmResourcesCache
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let languageSettingsCache: LanguageSettingsCacheType
    
    let completed: Signal = Signal()
    
    required init(realmDatabase: RealmDatabase, legacyRealmMigration: LegacyRealmMigration, attachmentsFileCache: AttachmentsFileCache, translationsFileCache: TranslationsFileCache, realmResourcesCache: RealmResourcesCache, favoritedResourcesCache: FavoritedResourcesCache, languageSettingsCache: LanguageSettingsCacheType) {
        
        self.realmDatabase = realmDatabase
        self.legacyRealmMigration = legacyRealmMigration
        self.attachmentsFileCache = attachmentsFileCache
        self.translationsFileCache = translationsFileCache
        self.realmResourcesCache = realmResourcesCache
        self.favoritedResourcesCache = favoritedResourcesCache
        self.languageSettingsCache = languageSettingsCache    }
    
    private var databaseIsEmpty: Bool {
        let mainThreadRealm: Realm = realmDatabase.mainThreadRealm
        return mainThreadRealm.objects(RealmResource.self).isEmpty || mainThreadRealm.objects(RealmLanguage.self).isEmpty
    }
    
    func loadAndCacheInitialDeviceResourcesIfNeeded(completeOnMain: @escaping (() -> Void)) {
        
        guard databaseIsEmpty else {
            completeOnMain()
            return
        }
        
        loadAndCacheLanguagesPlusResourcesPlusLatestAttachmentsAndTranslations { [weak self] (result: Result<ResourcesDownloaderResult, Error>?) in
            
            guard let downloadResult = result else {
                self?.handleLoadAndCacheInitialDeviceResourcesCompleted(completeOnMain: completeOnMain)
                return
            }
            
            self?.cacheAttachmentFiles(downloaderResult: downloadResult, complete: { [weak self] in
                
                self?.cacheTranslations { [weak self] in
                    
                    self?.setupInitialFavoritedResourcesAndLanguage { [weak self] in
                        
                        self?.handleLoadAndCacheInitialDeviceResourcesCompleted(completeOnMain: completeOnMain)
                    }
                }
            })
        }
    }
    
    private func loadAndCacheLanguagesPlusResourcesPlusLatestAttachmentsAndTranslations(complete: @escaping ((_ result: Result<ResourcesDownloaderResult, Error>?) -> Void)) {
                
        DispatchQueue.global().async { [weak self] in
            
            let jsonServices = JsonServices()
            
            let languagesData: Data? = jsonServices.getJsonData(fileName: "languages")
            let resourcesData: Data? = jsonServices.getJsonData(fileName: "resources")
                        
            let languagesResult: LanguagesDataModel? = jsonServices.decodeObject(data: languagesData)
            let resourcesResult: ResourcesPlusLatestTranslationsAndAttachmentsModel? = jsonServices.decodeObject(data: resourcesData)
                    
            if let languages = languagesResult?.data, let resources = resourcesResult {
                
                self?.realmResourcesCache.cacheResources(
                    languages: languages,
                    resourcesPlusLatestTranslationsAndAttachments: resources,
                    complete: complete
                )
            }
            else {
                complete(nil)
            }
        }
    }
    
    private func cacheAttachmentFiles(downloaderResult: Result<ResourcesDownloaderResult, Error>, complete: @escaping (() -> Void)) {
        
        switch downloaderResult {
            
        case .success(let result):
            
            guard !result.latestAttachmentFiles.isEmpty else {
                complete()
                return
            }
            
            for attachmentFile in result.latestAttachmentFiles {
                                                   
                cacheAttachmentFile(attachmentFile: attachmentFile, complete: {
                    
                    let reachedEnd: Bool = attachmentFile == result.latestAttachmentFiles.last
                    
                    if reachedEnd {
                        complete()
                    }
                })
            }
            
        case .failure(let error):
            assertionFailure(error.localizedDescription)
            complete()
        }
    }
    
    private func cacheAttachmentFile(attachmentFile: AttachmentFile, complete: @escaping (() -> Void)) {
        
        let location: SHA256FileLocation = attachmentFile.location
        
        guard let path = Bundle.main.path(forResource: location.sha256, ofType: location.pathExtension) else {
            complete()
            return
        }
        
        guard let image = UIImage(contentsOfFile: path) else {
            complete()
            return
        }
        
        let imageData: Data?
        
        if location.pathExtension == "png" {
            imageData = image.pngData()
        }
        else {
            imageData = image.jpegData(compressionQuality: 1)
        }
        
        guard let fileData = imageData else {
            complete()
            return
        }
        
        attachmentsFileCache.cacheAttachmentFile(attachmentFile: attachmentFile, fileData: fileData, complete: { (error: Error?) in
                        
            if let error = error {
                assertionFailure(error.localizedDescription)
            }

            complete()
        })
    }
    
    private func cacheTranslations(complete: @escaping (() -> Void)) {
        
        let translationIds: [String] = ["2351", "2615", "2767", "2776"]
        
        for translationId in translationIds {
    
            processTranslationId(translationId: translationId) {
                
                let finished: Bool = translationId == translationIds.last
                                
                if finished {
                    complete()
                }
            }
        }
    }
    
    private func processTranslationId(translationId: String, complete: @escaping (() -> Void)) {
        
        if let zipData = getTranslationZipData(filename: translationId) {
            
            translationsFileCache.cacheTranslationZipData(translationId: translationId, zipData: zipData) { (result: Result<TranslationManifestData, TranslationsFileCacheError>) in
                
                switch result {
                case .success( _):
                    break
                case .failure(let fileCacheError):
                    switch fileCacheError {
                    case .cacheError(let error):
                        print(" cache error: \(error)")
                    case .getManifestDataError(let error):
                        print(" get manifest error: \(error)")
                    case .sha256FileCacheError(let error):
                        print(" sha256 cache error: \(error)")
                    case .translationDoesNotExistInCache:
                        print(" translation does not exist in cache")
                    case .translationManifestDoesNotExistInFileCache:
                        print("  translation manifest does not exist in file cache")
                    }
                    assertionFailure("error cacheing translation zip")
                }
                complete()
            }
        }
        else {
            complete()
        }
    }
    
    private func getTranslationZipData(filename: String) -> Data? {
        
        if let filePath = Bundle.main.path(forResource: filename, ofType: "zip") {
            
            let url: URL = URL(fileURLWithPath: filePath)
            
            do {
                let data: Data = try Data(contentsOf: url, options: [])
                return data
            }
            catch let error {
                assertionFailure(error.localizedDescription)
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    private func setupInitialFavoritedResourcesAndLanguage(complete: @escaping (() -> Void)) {
                
        let realmDatabase: RealmDatabase = self.realmDatabase
        let legacyRealmMigration: LegacyRealmMigration = self.legacyRealmMigration
        
        legacyRealmMigration.migrateLegacyRealm { [weak self] (didMigrateLegacyRealm: Bool) in
            
            guard !didMigrateLegacyRealm else {
                complete()
                return
            }
                        
            // legacy realm was not migrated so setup data from initial device resources
            realmDatabase.background { [weak self] (realm: Realm) in
                
                self?.favoritedResourcesCache.addToFavorites(realm: realm, resourceId: "8") //teach me to share
                self?.favoritedResourcesCache.addToFavorites(realm: realm, resourceId: "2") //satisfied
                self?.favoritedResourcesCache.addToFavorites(realm: realm, resourceId: "1") //knowing god personally
                self?.favoritedResourcesCache.addToFavorites(realm: realm, resourceId: "4") //fourlaws

                if let englishLanguage = realm.objects(RealmLanguage.self).filter("code = 'en'").first {
                    self?.languageSettingsCache.cachePrimaryLanguageId(languageId: englishLanguage.id)
                }
                
                complete()
            }
        }
    }
    
    private func logDocuemntsContents() {
        
        let documentsPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        do {
                        
            let documentsContents: [String] = try FileManager.default.contentsOfDirectory(atPath: documentsPath)
        
            print("\nNUMBER OF DOCUMENTS: \(documentsContents.count)")
            for content in documentsContents {
                print("  content: \(content)")
            }
        }
        catch let error {
            //assertionFailure(error.localizedDescription)
        }
    }
    
    private func handleLoadAndCacheInitialDeviceResourcesCompleted(completeOnMain: @escaping (() -> Void)) {
                
        completed.accept()
        
        DispatchQueue.main.async {
            completeOnMain()
        }
    }
}
