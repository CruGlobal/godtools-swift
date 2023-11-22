//
//  GetToolShortcutLinksRepository.swift
//  godtools
//
//  Created by Levi Eggert on 11/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolShortcutLinksRepository: GetToolShortcutLinksRepositoryInterface {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
    }
    
    func getLinksPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[ToolShortcutLinkDomainModel], Never> {
        
        return favoritedResourcesRepository.getFavoritedResourcesSortedByCreatedAtPublisher(ascendingOrder: false)
            .flatMap({ (favoritedResources: [FavoritedResourceDataModel]) -> AnyPublisher<[ToolShortcutLinkDomainModel], Never> in
                
                let toolShortcutLinks: [ToolShortcutLinkDomainModel] = favoritedResources.compactMap({ (favoritedResource: FavoritedResourceDataModel) in
                    
                    guard let resource = self.resourcesRepository.getResource(id: favoritedResource.id) else {
                        return nil
                    }
                                        
                    return ToolShortcutLinkDomainModel(
                        appDeepLinkUrl: self.getToolUrlDeepLink(resource: resource, appLanguage: appLanguage),
                        title: self.getToolName(resource: resource, appLanguage: appLanguage)
                    )
                })
                
                return Just(toolShortcutLinks)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func getToolUrlDeepLink(resource: ResourceModel, appLanguage: AppLanguageDomainModel) -> String {
        
        return "godtools://knowgod.com/" + appLanguage + "/" + resource.abbreviation + "/0"
    }
    
    private func getToolName(resource: ResourceModel, appLanguage: AppLanguageDomainModel) -> String {
        
        let toolTranslation: TranslationModel?
        
        if let appLanguageTranslation = translationsRepository.getLatestTranslation(resourceId: resource.id, languageCode: appLanguage) {
            
            toolTranslation = appLanguageTranslation
        }
        else if let englishTranslation = translationsRepository.getLatestTranslation(resourceId: resource.id, languageCode: LanguageCodeDomainModel.english.value) {
            
            toolTranslation = englishTranslation
        }
        else {
            
            toolTranslation = nil
        }
        
        return toolTranslation?.translatedName ?? resource.name
    }
}
