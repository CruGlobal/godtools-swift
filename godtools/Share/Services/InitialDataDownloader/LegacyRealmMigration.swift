//
//  LegacyRealmMigration.swift
//  godtools
//
//  Created by Levi Eggert on 6/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class LegacyRealmMigration {
    
    private let legacyRealmDatabase: LegacyRealmDatabase
    private let realmDatabase: RealmDatabase
    private let languageSettingsCache: LanguageSettingsCacheType
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let downloadedLanguagesCache: DownloadedLanguagesCache
    
    required init(legacyRealmDatabase: LegacyRealmDatabase, realmDatabase: RealmDatabase, languageSettingsCache: LanguageSettingsCacheType, favoritedResourcesCache: FavoritedResourcesCache, downloadedLanguagesCache: DownloadedLanguagesCache) {
        
        self.legacyRealmDatabase = legacyRealmDatabase
        self.realmDatabase = realmDatabase
        self.languageSettingsCache = languageSettingsCache
        self.favoritedResourcesCache = favoritedResourcesCache
        self.downloadedLanguagesCache = downloadedLanguagesCache
    }
    
    func migrateLegacyRealm(complete: @escaping ((_ didMigrateLegacyRealm: Bool) -> Void)) {
        
        let legacyRealmDatabase: LegacyRealmDatabase = self.legacyRealmDatabase
        
        DispatchQueue.main.async { [weak self] in
            
            guard !legacyRealmDatabase.isEmpty else {
                complete(false)
                return
            }
            
            let legacyRealm: Realm = legacyRealmDatabase.mainThreadRealm
            
            let sortedLegacyResources: [DownloadedResource] = Array(legacyRealm.objects(DownloadedResource.self).sorted(byKeyPath: "sortOrder", ascending: false))
            let legacyLanguages: [Language] = Array(legacyRealm.objects(Language.self))
            
            for resource in sortedLegacyResources {
                if resource.shouldDownload {
                    self?.favoritedResourcesCache.addToFavorites(resourceId: resource.remoteId)
                }
            }
            
            for language in legacyLanguages {
                if language.shouldDownload {
                    self?.downloadedLanguagesCache.addDownloadedLanguage(languageId: language.remoteId)
                }
            }
            
            if let primaryLanguageId = self?.languageSettingsCache.primaryLanguageId.value {
                if let primaryLanguage = legacyRealm.object(ofType: Language.self, forPrimaryKey: primaryLanguageId) {
                    self?.languageSettingsCache.cachePrimaryLanguageId(languageId: primaryLanguage.remoteId)
                }
            }
            
            if let parallelLanguageId = self?.languageSettingsCache.parallelLanguageId.value {
                if let parallelLanguage = legacyRealm.object(ofType: Language.self, forPrimaryKey: parallelLanguageId) {
                    self?.languageSettingsCache.cacheParallelLanguageId(languageId: parallelLanguage.remoteId)
                }
            }
            
            // delete legacy realm database and files
            legacyRealmDatabase.deleteDatabase()
            
            // delete old attachments and translations directories
            let fileManager: FileManager = FileManager.default
            let documentsPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let legacyBannersPath: String = documentsPath.appending("/").appending("Banners")
            let legacyTranslationsPath: String = documentsPath.appending("/").appending("Resources")
            
            do {
                try fileManager.removeItem(atPath: legacyBannersPath)
                try fileManager.removeItem(atPath: legacyTranslationsPath)
            }
            catch {

            }
        
            complete(true)
        }
    }
}
