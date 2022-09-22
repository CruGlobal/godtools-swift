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
    
    private let getAllFavoritedResourceModelsUseCase: GetAllFavoritedResourceModelsUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getToolUseCase: GetToolUseCase
    private let resourcesRepository: ResourcesRepository
    
    init(getAllFavoritedResourceModelsUseCase: GetAllFavoritedResourceModelsUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getToolUseCase: GetToolUseCase, resourcesRepository: ResourcesRepository) {
        
        self.getAllFavoritedResourceModelsUseCase = getAllFavoritedResourceModelsUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getToolUseCase = getToolUseCase
        self.resourcesRepository = resourcesRepository
    }
    
    func getAllFavoritedToolsPublisher() -> AnyPublisher<[ToolDomainModel], Never> {
        
        return Publishers.CombineLatest(
            getAllFavoritedResourceModelsUseCase.getAllFavoritedResourceModelsPublisher(),
            getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            )
            .flatMap { favoritedResourceModels, primaryLanguage -> AnyPublisher<[ToolDomainModel], Never> in
                
                let favoritedTools = self.getFavoritedTools(from: favoritedResourceModels, with: primaryLanguage)
                
                return Just(favoritedTools)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getFavoritedTools() -> [ToolDomainModel] {
        
        let favoritedResourceModels = getAllFavoritedResourceModelsUseCase.getAllFavoritedResourceModels()
        let primaryLanguage = getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()
        
        return getFavoritedTools(from: favoritedResourceModels, with: primaryLanguage)
    }
    
    private func getFavoritedTools(from favoritedResourceModels: [FavoritedResourceModel], with primaryLanguage: LanguageDomainModel?) -> [ToolDomainModel] {
        
        let favoritedResourceIds: [String] = favoritedResourceModels.map { $0.resourceId }
                
        let favoritedResources = favoritedResourceIds
            .compactMap { id in
                return resourcesRepository.getResource(id: id)
            }
        
        guard let primaryLanguageId = primaryLanguage?.id else {
            return favoritedResources.map { getToolUseCase.getTool(resource: $0) }
        }
        
        let sortedTools = favoritedResources.enumerated().sorted { resourceWithOrderNumber1, resourceWithOrderNumber2 in
            
            func resourceHasTranslation(_ resource: ResourceModel) -> Bool {
                return resourcesRepository.getResourceLanguageLatestTranslation(resourceId: resource.id, languageId: primaryLanguageId) != nil
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
