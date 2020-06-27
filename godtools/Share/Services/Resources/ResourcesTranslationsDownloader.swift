//
//  ResourcesTranslationsDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 6/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class ResourcesTranslationsDownloader {
    
    private let realmDatabase: RealmDatabase
    private let resourcesCache: RealmResourcesCache
    private let favoritedResourcesCache: RealmFavoritedResourcesCache
    private let translationDownloader: TranslationDownloader
    
    required init(realmDatabase: RealmDatabase, resourcesCache: RealmResourcesCache, favoritedResourcesCache: RealmFavoritedResourcesCache, translationDownloader: TranslationDownloader) {
        
        self.realmDatabase = realmDatabase
        self.resourcesCache = resourcesCache
        self.favoritedResourcesCache = favoritedResourcesCache
        self.translationDownloader = translationDownloader
    }
    
    func downloadLanguageTranslationsForAllFavoritedResources(languageId: String, completeOnMain: @escaping ((_ downloadTranslationsReceipt: DownloadTranslationsReceipt?) -> Void)) {
        
        let translationDownloader: TranslationDownloader = self.translationDownloader
        
        realmDatabase.background { (realm: Realm) in
            
            let favoritedResources: [RealmFavoritedResource] = Array(realm.objects(RealmFavoritedResource.self))
            var translationIdsToDownload: [String] = Array()
            
            for favoritedResource in favoritedResources {
                
                if let realmResource = realm.object(ofType: RealmResource.self, forPrimaryKey: favoritedResource.resourceId), let languageTranslation = realmResource.latestTranslations.filter("language.id = '\(languageId)'").first {
                    translationIdsToDownload.append(languageTranslation.id)
                }
            }
            
            let receipt = translationDownloader.downloadTranslations(translationIds: translationIdsToDownload)
            
            DispatchQueue.main.async {
                completeOnMain(receipt)
            }
        }
    }
    
    func downloadLanguageTranslationsForResource(resourceId: String, languageIds: [String], completeOnMain: @escaping ((_ downloadTranslationsReceipt: DownloadTranslationsReceipt?) -> Void)) {
        
        let translationDownloader: TranslationDownloader = self.translationDownloader
        
        realmDatabase.background { (realm: Realm) in
            
            var translationIdsToDownload: [String] = Array()
            
            if let realmResource = realm.object(ofType: RealmResource.self, forPrimaryKey: resourceId) {
    
                for languageId in languageIds {
                    
                    guard !languageId.isEmpty else {
                        continue
                    }
                    
                    if let languageTranslation = realmResource.latestTranslations.filter("language.id = '\(languageId)'").first {
                        translationIdsToDownload.append(languageTranslation.id)
                    }
                }
            }
            
            let receipt = translationDownloader.downloadTranslations(translationIds: translationIdsToDownload)
            
            DispatchQueue.main.async {
                completeOnMain(receipt)
            }
        }
    }
    
    func downloadLatestTranslationsForAllFavoritedResources(completeOnMain: @escaping ((_ downloadTranslationsReceipt: DownloadTranslationsReceipt?) -> Void)) {
        
        let translationDownloader: TranslationDownloader = self.translationDownloader
        
        realmDatabase.background { (realm: Realm) in
            
            let favoritedResources: [RealmFavoritedResource] = Array(realm.objects(RealmFavoritedResource.self))
            var translationIdsToDownload: [String] = Array()
            
            for favoritedResource in favoritedResources {
                
                if let realmResource = realm.object(ofType: RealmResource.self, forPrimaryKey: favoritedResource.resourceId) {
                    
                    translationIdsToDownload.append(contentsOf: Array(realmResource.latestTranslationIds))
                }
            }
            
            let receipt = translationDownloader.downloadTranslations(translationIds: translationIdsToDownload)
            
            DispatchQueue.main.async {
                completeOnMain(receipt)
            }
        }
    }
}
