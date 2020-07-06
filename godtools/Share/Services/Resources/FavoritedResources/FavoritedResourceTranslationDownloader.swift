//
//  FavoritedResourceTranslationDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 6/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class FavoritedResourceTranslationDownloader: NSObject {
        
    private let realmDatabase: RealmDatabase
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let downloadedLanguagesCache: DownloadedLanguagesCache
    private let translationDownloader: TranslationDownloader
    
    required init(realmDatabase: RealmDatabase, favoritedResourcesCache: FavoritedResourcesCache, downloadedLanguagesCache: DownloadedLanguagesCache, translationDownloader: TranslationDownloader) {
        
        self.realmDatabase = realmDatabase
        self.favoritedResourcesCache = favoritedResourcesCache
        self.downloadedLanguagesCache = downloadedLanguagesCache
        self.translationDownloader = translationDownloader
        
        super.init()
        
        setupBinding()
    }
    
    deinit {
        
        favoritedResourcesCache.resourceFavorited.removeObserver(self)
    }
    
    private func setupBinding() {
        
        favoritedResourcesCache.resourceFavorited.addObserver(self) { [weak self] (resourceId: String) in
            self?.realmDatabase.background { [weak self] (realm: Realm) in
                _ = self?.downloadAllDownloadedLanguagesTranslationsForResource(
                    realm: realm,
                    resourceId: resourceId
                )
            }
        }
    }
    
    func downloadAllDownloadedLanguagesTranslationsForAllFavoritedResources(realm: Realm) -> DownloadResourceTranslationsReceipts {
        
        let downloadTranslationsReceipts: DownloadResourceTranslationsReceipts = DownloadResourceTranslationsReceipts()
        
        let favoritedResources: [FavoritedResourceModel] = favoritedResourcesCache.getFavoritedResources(realm: realm)
        
        for favoritedResource in favoritedResources {
            
            let receipt: DownloadTranslationsReceipt? = downloadAllDownloadedLanguagesTranslationsForResource(
                realm: realm,
                resourceId: favoritedResource.resourceId
            )
            
            if let receipt = receipt {
                downloadTranslationsReceipts.addReceipt(
                    resourceId: favoritedResource.resourceId,
                    receipt: receipt
                )
            }
        }
        
        return downloadTranslationsReceipts
    }
    
    private func downloadAllDownloadedLanguagesTranslationsForResource(realm: Realm, resourceId: String) -> DownloadTranslationsReceipt? {
        
        let downloadedLanguages: [DownloadedLanguageModel] = downloadedLanguagesCache.getDownloadedLanguages(realm: realm)
        
        guard let realmResource = realm.object(ofType: RealmResource.self, forPrimaryKey: resourceId) else {
            return nil
        }
        
        var translationIdsToDownload: [String] = Array()
                
        for language in downloadedLanguages {
            
            if let languageTranslation = realmResource.latestTranslations.filter("language.id = '\(language.languageId)'").first {
                translationIdsToDownload.append(languageTranslation.id)
            }
        }
        
        guard !translationIdsToDownload.isEmpty else {
            return nil
        }
        
        return translationDownloader.downloadTranslations(realm: realm, translationIds: translationIdsToDownload)
    }
}
