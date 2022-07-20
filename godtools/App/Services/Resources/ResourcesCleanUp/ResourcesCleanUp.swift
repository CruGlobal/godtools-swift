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
    
    private let realmDatabase: RealmDatabase
    private let translationsFileCache: TranslationsFileCache
    private let resourcesSHA256FileCache: ResourcesSHA256FileCache
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let downloadedLanguagesCache: DownloadedLanguagesCache
    
    required init(realmDatabase: RealmDatabase, translationsFileCache: TranslationsFileCache, resourcesSHA256FileCache: ResourcesSHA256FileCache, favoritedResourcesCache: FavoritedResourcesCache, downloadedLanguagesCache: DownloadedLanguagesCache) {
        
        self.realmDatabase = realmDatabase
        self.translationsFileCache = translationsFileCache
        self.resourcesSHA256FileCache = resourcesSHA256FileCache
        self.favoritedResourcesCache = favoritedResourcesCache
        self.downloadedLanguagesCache = downloadedLanguagesCache
    }
    
    func bulkDeleteResourcesIfNeeded(cacheResult: ResourcesCacheResult) {
        
        realmDatabase.background { [weak self] (realm: Realm) in
            
            self?.bulkDeleteResourcesIfNeeded(realm: realm, cacheResult: cacheResult)
        }
    }
    
    func bulkDeleteResourcesIfNeeded(realm: Realm, cacheResult: ResourcesCacheResult) {
        
        // TODO: Need to finish resources clean up.  Currently only languages are cleaned up. ~Levi
        
        print("\nResourcesCleanUp: bulkDeleteResourcesIfNeeded()")
        
        /*
        translationsFileCache.bulkDeleteTranslationZipFiles(
            realm: realm,
            resourceIds: cacheResult.resourceIdsRemoved,
            languageIds: cacheResult.languageIdsRemoved,
            translationIds: cacheResult.translationIdsRemoved
        )*/

        //resourcesSHA256FileCache.deleteUnusedSHA256ResourceFiles(realm: realm)

        //favoritedResourcesCache.bulkDeleteFavoritedResources(realm: realm, resourceIds: cacheResult.resourceIdsRemoved)

        downloadedLanguagesCache.bulkDeleteDownloadedLanguages(realm: realm, languageIds: cacheResult.languageIdsRemoved)
        
        //translationsFileCache.deleteUnusedTranslationZipFiles(realm: realm)
        
        print("   total realm translation zip files: \(realm.objects(RealmTranslationZipFile.self).count)")
        print("   total realm sha256 resource files: \(realm.objects(RealmSHA256File.self).count)")
        
        /*
        switch resourcesSHA256FileCache.getContentsOfRootDirectory() {
        case .success(let contents):
            print("   total resources files count: \(contents.count)")
        case .failure(let error):
            print("   fetch resources contents error: \(error)")
        }*/
    }
}
