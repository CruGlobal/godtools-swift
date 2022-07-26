//
//  InitialDeviceResourcesLoader.swift
//  godtools
//
//  Created by Levi Eggert on 6/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import RealmSwift

class InitialDeviceResourcesLoader {
    
    private let realmDatabase: RealmDatabase
    private let legacyRealmMigration: LegacyRealmMigration
    private let attachmentsFileCache: AttachmentsFileCache
    private let translationsFileCache: TranslationsFileCache
    private let realmResourcesCache: RealmResourcesCache
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let languagesCache: RealmLanguagesCache
    private let deviceLanguage: DeviceLanguageType
    private let languageSettingsCache: LanguageSettingsCacheType
        
    required init(realmDatabase: RealmDatabase, legacyRealmMigration: LegacyRealmMigration, attachmentsFileCache: AttachmentsFileCache, translationsFileCache: TranslationsFileCache, realmResourcesCache: RealmResourcesCache, favoritedResourcesCache: FavoritedResourcesCache, languagesCache: RealmLanguagesCache, deviceLanguage: DeviceLanguageType, languageSettingsCache: LanguageSettingsCacheType) {
        
        self.realmDatabase = realmDatabase
        self.legacyRealmMigration = legacyRealmMigration
        self.attachmentsFileCache = attachmentsFileCache
        self.translationsFileCache = translationsFileCache
        self.realmResourcesCache = realmResourcesCache
        self.favoritedResourcesCache = favoritedResourcesCache
        self.languagesCache = languagesCache
        self.deviceLanguage = deviceLanguage
        self.languageSettingsCache = languageSettingsCache
    }
    
    func loadAndCacheInitialDeviceResourcesIfNeeded(completeOnMain: @escaping (() -> Void)) {
        
        guard !realmResourcesCache.resourcesAvailable else {
            completeOnMain()
            return
        }
        
        loadAndCacheLanguagesPlusResourcesPlusLatestAttachmentsAndTranslations { [weak self] (result: Result<ResourcesCacheResult, Error>?) in
            
            guard let cacheResult = result else {
                self?.handleLoadAndCacheInitialDeviceResourcesCompleted(completeOnMain: completeOnMain)
                return
            }
            
            self?.cacheAttachmentFiles(cacheResult: cacheResult, complete: { [weak self] in
                
                self?.setupInitialFavoritedResourcesAndLanguage { [weak self] in
                    
                    self?.handleLoadAndCacheInitialDeviceResourcesCompleted(completeOnMain: completeOnMain)
                }
            })
        }
    }
    
    private func loadAndCacheLanguagesPlusResourcesPlusLatestAttachmentsAndTranslations(complete: @escaping ((_ result: Result<ResourcesCacheResult, Error>?) -> Void)) {
        
        let realmResourcesCache: RealmResourcesCache = self.realmResourcesCache
        
        realmDatabase.background { (realm: Realm) in
            
            let jsonServices = JsonServices()
            
            let languagesData: Data? = jsonServices.getJsonData(fileName: "languages")
            let resourcesData: Data? = jsonServices.getJsonData(fileName: "resources")
                        
            let languagesResult: LanguagesDataModel? = jsonServices.decodeObject(data: languagesData)
            let resourcesResult: ResourcesPlusLatestTranslationsAndAttachmentsModel? = jsonServices.decodeObject(data: resourcesData)
                    
            if let languages = languagesResult?.data, let resources = resourcesResult {
                
                let downloaderResult = ResourcesDownloaderResult(
                    languages: languages,
                    resourcesPlusLatestTranslationsAndAttachments: resources
                )
                
                let result: Result<ResourcesCacheResult, Error> = realmResourcesCache.cacheResources(realm: realm, downloaderResult: downloaderResult)
                
                complete(result)
            }
            else {
                complete(nil)
            }
        }
    }
    
    private func cacheAttachmentFiles(cacheResult: Result<ResourcesCacheResult, Error>, complete: @escaping (() -> Void)) {
        
        switch cacheResult {
            
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
                
                self?.favoritedResourcesCache.addToFavorites(realm: realm, resourceId: "2") //satisfied
                self?.favoritedResourcesCache.addToFavorites(realm: realm, resourceId: "1") //knowing god personally
                self?.favoritedResourcesCache.addToFavorites(realm: realm, resourceId: "4") //fourlaws
                self?.favoritedResourcesCache.addToFavorites(realm: realm, resourceId: "8") //teach me to share
                
                self?.choosePrimaryLanguageIfNeeded(realm: realm)
                
                complete()
            }
        }
    }
    
    private func handleLoadAndCacheInitialDeviceResourcesCompleted(completeOnMain: @escaping (() -> Void)) {
                        
        DispatchQueue.main.async {
            completeOnMain()
        }
    }
    
    func choosePrimaryLanguageIfNeeded(realm: Realm) {
                
        let cachedPrimaryLanguageId: String = languageSettingsCache.primaryLanguageId.value ?? ""
        let cachedPrimaryLanguage: RealmLanguage? = languagesCache.getLanguage(realm: realm, id: cachedPrimaryLanguageId)
        let primaryLanguageIsCached: Bool = cachedPrimaryLanguage != nil
        
        if primaryLanguageIsCached {
            return
        }
                
        let preferredDeviceLanguageCodes: [String] = deviceLanguage.possibleLocaleCodes(locale: Locale.current)
        
        var deviceLanguage: LanguageModel?
        
        for languageCode in preferredDeviceLanguageCodes {
            if let cachedLanguage = languagesCache.getLanguage(realm: realm, code: languageCode) {
                deviceLanguage = LanguageModel(model: cachedLanguage)
                break
            }
        }
        
        let primaryLanguage: LanguageModel?
        
        if let deviceLanguage = deviceLanguage {
            primaryLanguage = deviceLanguage
        }
        else if let cachedEnglishLanguage = languagesCache.getLanguage(realm: realm, code: "en") {
            primaryLanguage = LanguageModel(model: cachedEnglishLanguage)
        }
        else {
            primaryLanguage = nil
        }
        
        if let primaryLanguage = primaryLanguage {
            languageSettingsCache.cachePrimaryLanguageId(languageId: primaryLanguage.id)
        }
    }
}
