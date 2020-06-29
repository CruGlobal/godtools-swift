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
    
    typealias ResourceId = String
    
    private let realmDatabase: RealmDatabase
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let downloadedLanguagesCache: DownloadedLanguagesCache
    private let translationDownloader: TranslationDownloader
    
    private var downloadResourceTranslationsReceipts: [ResourceId: DownloadTranslationsReceipt] = Dictionary()
    
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
                self?.downloadAllDownloadedLanguagesTranslationsForResource(
                    realm: realm,
                    resourceId: resourceId
                )
            }
        }
    }
    
    func downloadAllDownloadedLanguagesTranslationsForAllFavoritedResources() {
        
        realmDatabase.background { [weak self] (realm: Realm) in
            
            let favoritedResources: [FavoritedResourceModel] = self?.favoritedResourcesCache.getFavoritedResources(realm: realm) ?? []
            
            for favoritedResource in favoritedResources {
                
                self?.downloadAllDownloadedLanguagesTranslationsForResource(
                    realm: realm,
                    resourceId: favoritedResource.resourceId
                )
            }
        }
    }
    
    private func downloadAllDownloadedLanguagesTranslationsForResource(realm: Realm, resourceId: String) {
        
        let downloadedLanguages: [DownloadedLanguageModel] = downloadedLanguagesCache.getDownloadedLanguages(realm: realm)
        
        guard !downloadedLanguages.isEmpty else {
            return
        }
        
        guard let realmResource = realm.object(ofType: RealmResource.self, forPrimaryKey: resourceId) else {
            return
        }
        
        var translationIdsToDownload: [String] = Array()
                
        for language in downloadedLanguages {
            
            guard !language.languageId.isEmpty else {
                continue
            }
            
            if let languageTranslation = realmResource.latestTranslations.filter("language.id = '\(language.languageId)'").first {
                translationIdsToDownload.append(languageTranslation.id)
            }
        }
        
        let receipt: DownloadTranslationsReceipt? = translationDownloader.downloadTranslations(realm: realm, translationIds: translationIdsToDownload)
        
        if let receipt = receipt {
            
            receipt.completed.addObserver(self) { [weak self] in
                
                self?.downloadResourceTranslationsReceipts[resourceId] = nil
            }
         
            downloadResourceTranslationsReceipts[resourceId] = receipt
        }
    }
}
