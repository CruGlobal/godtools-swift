//
//  ResourcesCleanUp.swift
//  godtools
//
//  Created by Levi Eggert on 7/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class ResourcesCleanUp {
    
    private let translationsFileCache: TranslationsFileCache
    private let resourcesSHA256FileCache: ResourcesSHA256FileCache
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let downloadedLanguagesCache: DownloadedLanguagesCache
    
    required init(translationsFileCache: TranslationsFileCache, resourcesSHA256FileCache: ResourcesSHA256FileCache, favoritedResourcesCache: FavoritedResourcesCache, downloadedLanguagesCache: DownloadedLanguagesCache) {
        
        self.translationsFileCache = translationsFileCache
        self.resourcesSHA256FileCache = resourcesSHA256FileCache
        self.favoritedResourcesCache = favoritedResourcesCache
        self.downloadedLanguagesCache = downloadedLanguagesCache
    }
    
    func bulkDeleteResourcesIfNeeded(realm: Realm, cacheResult: ResourcesCacheResult) {
        
        guard cacheResult.didRemoveCachedResources else {
            return
        }
                
        translationsFileCache.bulkDeleteTranslationZipFiles(
            realm: realm,
            resourceIds: cacheResult.resourceIdsRemoved,
            languageIds: cacheResult.languageIdsRemoved,
            translationIds: cacheResult.translationIdsRemoved
        )

        resourcesSHA256FileCache.deleteUnusedSHA256ResourceFiles(realm: realm)

        favoritedResourcesCache.bulkDeleteFavoritedResources(realm: realm, resourceIds: cacheResult.resourceIdsRemoved)

        downloadedLanguagesCache.bulkDeleteDownloadedLanguages(realm: realm, languageIds: cacheResult.languageIdsRemoved)
    }
}
