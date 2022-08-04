//
//  LanguageTranslationsDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 6/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class LanguageTranslationsDownloader: NSObject {
    
    typealias LanguageId = String
    
    private let realmDatabase: RealmDatabase
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let languageSettingsService: LanguageSettingsService
    private let downloadedLanguagesCache: DownloadedLanguagesCache
    private let translationDownloader: TranslationDownloader
        
    required init(realmDatabase: RealmDatabase, favoritedResourcesCache: FavoritedResourcesCache, languageSettingsService: LanguageSettingsService, downloadedLanguagesCache: DownloadedLanguagesCache, translationDownloader: TranslationDownloader) {
        
        self.realmDatabase = realmDatabase
        self.favoritedResourcesCache = favoritedResourcesCache
        self.languageSettingsService = languageSettingsService
        self.downloadedLanguagesCache = downloadedLanguagesCache
        self.translationDownloader = translationDownloader
        
        super.init()
        
        setupBinding()
    }
    
    deinit {
        languageSettingsService.primaryLanguage.removeObserver(self)
        languageSettingsService.parallelLanguage.removeObserver(self)
    }
    
    private func setupBinding() {
        
        languageSettingsService.primaryLanguage.addObserver(self) { [weak self] (primaryLanguage: LanguageModel?) in
            
            if let primaryLanguage = primaryLanguage {
                self?.downloadLanguageTranslationsForAllFavoritedResources(languageId: primaryLanguage.id)
            }
        }
        
        languageSettingsService.parallelLanguage.addObserver(self) { [weak self] (parallelLanguage: LanguageModel?) in
            
            if let parallelLanguage = parallelLanguage {
                self?.downloadLanguageTranslationsForAllFavoritedResources(languageId: parallelLanguage.id)
            }
        }
    }
    
    private func downloadLanguageTranslationsForAllFavoritedResources(languageId: String) {
        
        guard !languageId.isEmpty else {
            return
        }
        
        /*
        
        downloadedLanguagesCache.addDownloadedLanguage(realm: realm, languageId: languageId)
        
        let favoritedResources: [FavoritedResourceModel] = favoritedResourcesCache.getFavoritedResources()
        var translationIdsToDownload: [String] = Array()
        
        for favoritedResource in favoritedResources {
            
            if let realmResource = realm.object(ofType: RealmResource.self, forPrimaryKey: favoritedResource.resourceId), let languageTranslation = realmResource.latestTranslations.filter("language.id = '\(languageId)'").first {
                translationIdsToDownload.append(languageTranslation.id)
            }
        }
        
        _ = translationDownloader.downloadAndCacheTranslationManifests(realm: realm, translationIds: translationIdsToDownload)*/
    }
}
