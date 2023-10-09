//
//  GetAllFavoritedToolsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/3/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAllFavoritedToolsUseCase {
    
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getToolUseCase: GetToolUseCase
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
    
    init(getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getToolUseCase: GetToolUseCase, favoritedResourcesRepository: FavoritedResourcesRepository, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository) {
        
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getToolUseCase = getToolUseCase
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
    }
    
    func getAllFavoritedToolsPublisher() -> AnyPublisher<[ToolDomainModel], Never> {
        
        return Publishers.CombineLatest(
            favoritedResourcesRepository.getFavoritedResourcesChangedPublisher(),
            getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
        )
            .flatMap({ (favoritedResourcesChanged: Void, primaryLanguage: LanguageDomainModel?) -> AnyPublisher<[ToolDomainModel], Never> in
                                
                let favoritedTools: [ToolDomainModel] = self.getFavoritedTools(with: primaryLanguage)
                
                return Just(favoritedTools)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func getFavoritedTools() -> [ToolDomainModel] {
        
        let primaryLanguage = getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()
        
        return getFavoritedTools(with: primaryLanguage)
    }
    
    private func getFavoritedTools(with primaryLanguage: LanguageDomainModel?) -> [ToolDomainModel] {
        
        let favoritedResourceModels: [FavoritedResourceDataModel] = favoritedResourcesRepository.getFavoritedResourcesSortedByCreatedAt(ascendingOrder: false)
        let favoritedResourceIds: [String] = favoritedResourceModels.map { $0.id }
                
        let favoritedResources = favoritedResourceIds
            .compactMap { id in
                return resourcesRepository.getResource(id: id)
            }
        
        guard let primaryLanguageId = primaryLanguage?.id else {
            return favoritedResources.map { getToolUseCase.getTool(resource: $0) }
        }
        
        let sortedTools = favoritedResources.enumerated().sorted { resourceWithOrderNumber1, resourceWithOrderNumber2 in
            
            func resourceHasTranslation(_ resource: ResourceModel) -> Bool {
                return translationsRepository.getLatestTranslation(resourceId: resource.id, languageId: primaryLanguageId) != nil
            }
            
            func isInOriginalOrder() -> Bool {
                resourceWithOrderNumber1.offset < resourceWithOrderNumber2.offset
            }
            
            if resourceHasTranslation(resourceWithOrderNumber1.element) {
                
                if resourceHasTranslation(resourceWithOrderNumber2.element) {
                    return isInOriginalOrder()
                    
                } else {
                    return true
                }
                
            } else if resourceHasTranslation(resourceWithOrderNumber2.element) {
                
                return false
                
            } else {
                return isInOriginalOrder()
            }
        }
            .map { getToolUseCase.getTool(resource: $0.element) }
        
        return sortedTools
        
    }
}
