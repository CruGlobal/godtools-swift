//
//  GetToolShortcutLinksUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetToolShortcutLinksUseCase {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
    private let maxNumberOfToolShortcutLinks: Int = 4
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[ToolShortcutLinkDomainModel], Error> {
        
        return favoritedResourcesRepository
            .persistence
            .observeCollectionChangesPublisher()
            .flatMap { (favoritesChanged: Void) -> AnyPublisher<[FavoritedResourceDataModel], Error> in
                
                return self.favoritedResourcesRepository
                    .getFavoritedResourcesSortedByPositionPublisher()
            }
            .tryMap { (favoritedResources: [FavoritedResourceDataModel]) in
                
                return try self.getToolShortcutLinks(
                    appLanguage: appLanguage,
                    favoritedResources: favoritedResources
                )
            }
            .eraseToAnyPublisher()
    }
    
    private func getToolShortcutLinks(appLanguage: AppLanguageDomainModel, favoritedResources: [FavoritedResourceDataModel]) throws -> [ToolShortcutLinkDomainModel] {
        
        let toolShortcutLinks: [ToolShortcutLinkDomainModel] = try favoritedResources
            .prefix(self.maxNumberOfToolShortcutLinks)
            .compactMap { (favoritedResource: FavoritedResourceDataModel) in
                
                guard let resource = try resourcesRepository.persistence.getDataModel(id: favoritedResource.id) else {
                    return nil
                }
                
                return ToolShortcutLinkDomainModel(
                    appDeepLinkUrl: self.getToolUrlDeepLink(resource: resource, appLanguage: appLanguage),
                    title: self.getToolName(resource: resource, appLanguage: appLanguage)
                )
            }
        
        return toolShortcutLinks
    }
    
    private func getToolUrlDeepLink(resource: ResourceDataModel, appLanguage: AppLanguageDomainModel) -> String {
        
        return "godtools://knowgod.com/" + appLanguage + "/" + resource.abbreviation + "/0"
    }
    
    private func getToolName(resource: ResourceDataModel, appLanguage: AppLanguageDomainModel) -> String {
        
        let toolTranslation: TranslationDataModel?
        
        if let appLanguageTranslation = translationsRepository.cache.getLatestTranslation(resourceId: resource.id, languageCode: appLanguage) {
            
            toolTranslation = appLanguageTranslation
        }
        else if let englishTranslation = translationsRepository.cache.getLatestTranslation(resourceId: resource.id, languageCode: LanguageCodeDomainModel.english.value) {
            
            toolTranslation = englishTranslation
        }
        else {
            
            toolTranslation = nil
        }
        
        return toolTranslation?.translatedName ?? resource.name
    }
}
