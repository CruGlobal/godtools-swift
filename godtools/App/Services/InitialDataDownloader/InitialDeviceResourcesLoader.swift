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
    private let attachmentsFileCache: AttachmentsFileCache
    private let resourcesSync: InitialDataDownloaderResourcesSync
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let languagesCache: RealmLanguagesCache
    private let deviceLanguage: DeviceLanguage
        
    required init(realmDatabase: RealmDatabase, attachmentsFileCache: AttachmentsFileCache, resourcesSync: InitialDataDownloaderResourcesSync, favoritedResourcesCache: FavoritedResourcesCache, languagesCache: RealmLanguagesCache, deviceLanguage: DeviceLanguage) {
        
        self.realmDatabase = realmDatabase
        self.attachmentsFileCache = attachmentsFileCache
        self.resourcesSync = resourcesSync
        self.favoritedResourcesCache = favoritedResourcesCache
        self.languagesCache = languagesCache
        self.deviceLanguage = deviceLanguage
    }
    
    func loadAndCacheInitialDeviceResourcesIfNeeded(completeOnMain: @escaping (() -> Void)) {
        
        guard !resourcesSync.resourcesAvailable else {
            completeOnMain()
            return
        }
        
        loadAndCacheLanguagesPlusResourcesPlusLatestAttachmentsAndTranslations { [weak self] (result: Result<ResourcesCacheResult, Error>?) in
            
            guard let cacheResult = result else {
                self?.handleLoadAndCacheInitialDeviceResourcesCompleted(completeOnMain: completeOnMain)
                return
            }
            
            self?.cacheAttachmentFiles(cacheResult: cacheResult, complete: { [weak self] in
                
                self?.setupInitialFavoritedResourcesAndLanguage()
                self?.handleLoadAndCacheInitialDeviceResourcesCompleted(completeOnMain: completeOnMain)
            })
        }
    }
    
    private func loadAndCacheLanguagesPlusResourcesPlusLatestAttachmentsAndTranslations(complete: @escaping ((_ result: Result<ResourcesCacheResult, Error>?) -> Void)) {
        
        let resourcesSync: InitialDataDownloaderResourcesSync = self.resourcesSync
        
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
                
                let result: Result<ResourcesCacheResult, Error> = resourcesSync.cacheResources(realm: realm, downloaderResult: downloaderResult)
                
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
    
    private func setupInitialFavoritedResourcesAndLanguage() {
                
        favoritedResourcesCache.addToFavorites(resourceId: "2") //satisfied
        favoritedResourcesCache.addToFavorites(resourceId: "1") //knowing god personally
        favoritedResourcesCache.addToFavorites(resourceId: "4") //fourlaws
        favoritedResourcesCache.addToFavorites(resourceId: "8") //teach me to share
    }
    
    private func handleLoadAndCacheInitialDeviceResourcesCompleted(completeOnMain: @escaping (() -> Void)) {
                        
        DispatchQueue.main.async {
            completeOnMain()
        }
    }
}
