//
//  FetchTranslationManifestsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class FetchTranslationManifestsViewModel {
        
    typealias LanguageId = String
    
    private let realmDatabase: RealmDatabase
    private let resourcesCache: RealmResourcesCache
    private let languageSettingsService: LanguageSettingsService
    private let translationsFileCache: TranslationsFileCache
    
    required init(realmDatabase: RealmDatabase, resourcesCache: RealmResourcesCache, languageSettingsService: LanguageSettingsService, translationsFileCache: TranslationsFileCache) {
        
        self.realmDatabase = realmDatabase
        self.resourcesCache = resourcesCache
        self.languageSettingsService = languageSettingsService
        self.translationsFileCache = translationsFileCache
    }
    
    func getTranslationManifests(resourceId: String, completeOnMain: @escaping ((_ result: FetchTranslationManifestResult) -> Void)) {
                
        realmDatabase.background { [weak self] (realm: Realm) in
            guard let viewModel = self else {
                return
            }
            
            let result: FetchTranslationManifestResult = viewModel.getTranslationManifests(
                realm: realm,
                resourceId: resourceId
            )
            
            DispatchQueue.main.async {
                completeOnMain(result)
            }
        }
    }
    
    private func getTranslationManifests(realm: Realm, resourceId: String) -> FetchTranslationManifestResult {
            
        guard let realmResource = realm.object(ofType: RealmResource.self, forPrimaryKey: resourceId) else {
            return .failedToGetInitialResourcesFromCache
        }
        
        let resource: ResourceModel = ResourceModel(realmResource: realmResource)
        
        // first fetch primary language translation from cache
        
        let primaryLanguageId: String = languageSettingsService.languageSettingsCache.primaryLanguageId.value ?? ""
        let primaryTranslation: TranslationModel?
        
        if let primaryLanguageTranslation = resourcesCache.getResourceLanguageTranslation(realm: realm, resourceId: resourceId, languageId: primaryLanguageId) {
            primaryTranslation = primaryLanguageTranslation
        }
        else if let englishLanguageTranslation = resourcesCache.getResourceLanguageTranslation(realm: realm, resourceId: resourceId, languageCode: "en") {
            primaryTranslation = englishLanguageTranslation
        }
        else {
            primaryTranslation = nil
        }
        
        guard let resourcePrimaryTranslation = primaryTranslation, let resourcePrimaryLanguage = primaryTranslation?.language else {
            return .failedToGetInitialResourcesFromCache
        }
        
        // fetch primary translation manifest from cache
        
        let primaryTranslationId: String = resourcePrimaryTranslation.id
        let primaryManifest: TranslationManifestData?
        
        let primaryManifestResult: Result<TranslationManifestData, TranslationsFileCacheError> = translationsFileCache.getTranslationManifest(realm: realm, translationId: primaryTranslationId)
        
        switch primaryManifestResult {
        case .success(let translationManifestData):
            primaryManifest = translationManifestData
        case .failure(let error):
            primaryManifest = nil
        }
        
        // fetch parallel if needed
        
        let resourceType: ResourceType = ResourceType.resourceType(resource: resource)
        let parallelLanguageId: String = languageSettingsService.languageSettingsCache.parallelLanguageId.value ?? ""
        let parallelSupported: Bool = resource.supportsLanguage(languageId: parallelLanguageId) && resourceType != .article
        
        guard parallelSupported else {
            return .fetchedTranslationsFromCache(
                primaryLanguage: resourcePrimaryLanguage,
                primaryTranslation: resourcePrimaryTranslation,
                primaryTranslationManifest: primaryManifest,
                parallelLanguage: nil,
                parallelTranslation: nil,
                parallelTranslationManifest: nil
            )
        }
        
        guard let resourceParallelLanguageTranslation = resourcesCache.getResourceLanguageTranslation(realm: realm, resourceId: resourceId, languageId: parallelLanguageId) else {
            return .fetchedTranslationsFromCache(
                primaryLanguage: resourcePrimaryLanguage,
                primaryTranslation: resourcePrimaryTranslation,
                primaryTranslationManifest: primaryManifest,
                parallelLanguage: nil,
                parallelTranslation: nil,
                parallelTranslationManifest: nil
            )
        }
        
        let parallelTranslationId: String = resourceParallelLanguageTranslation.id
        let parallelManifest: TranslationManifestData?
        
        let parallelManifestResult: Result<TranslationManifestData, TranslationsFileCacheError> = translationsFileCache.getTranslationManifest(realm: realm, translationId: parallelTranslationId)
        
        switch parallelManifestResult {
        case .success(let translationManifestData):
            parallelManifest = translationManifestData
        case .failure(let error):
            parallelManifest = nil
        }
        
        return .fetchedTranslationsFromCache(
            primaryLanguage: resourcePrimaryLanguage,
            primaryTranslation: resourcePrimaryTranslation,
            primaryTranslationManifest: primaryManifest,
            parallelLanguage: resourceParallelLanguageTranslation.language,
            parallelTranslation: resourceParallelLanguageTranslation,
            parallelTranslationManifest: parallelManifest
        )
    }
}
