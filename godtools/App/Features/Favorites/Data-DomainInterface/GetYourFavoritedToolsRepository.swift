//
//  GetYourFavoritedToolsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 2/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetYourFavoritedToolsRepository: GetYourFavoritedToolsRepositoryInterface {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    private let resourcesRepository: ResourcesRepository
    private let getTranslatedToolName: GetTranslatedToolName
    private let getTranslatedToolCategory: GetTranslatedToolCategory
    private let getToolListItemInterfaceStringsRepository: GetToolListItemInterfaceStringsRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository, resourcesRepository: ResourcesRepository, getTranslatedToolName: GetTranslatedToolName, getTranslatedToolCategory: GetTranslatedToolCategory, getToolListItemInterfaceStringsRepository: GetToolListItemInterfaceStringsRepository) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.resourcesRepository = resourcesRepository
        self.getTranslatedToolName = getTranslatedToolName
        self.getTranslatedToolCategory = getTranslatedToolCategory
        self.getToolListItemInterfaceStringsRepository = getToolListItemInterfaceStringsRepository
    }
    
    func getToolsPublisher(translateInLanguage: AppLanguageDomainModel, maxCount: Int?) -> AnyPublisher<[YourFavoritedToolDomainModel], Never> {
        
        return Publishers.CombineLatest3(
            resourcesRepository.getResourcesChangedPublisher(),
            getToolListItemInterfaceStringsRepository.getStringsPublisher(translateInLanguage: translateInLanguage),
            favoritedResourcesRepository.getFavoritedResourcesSortedByPositionPublisher()
        )
        .flatMap({ (resourcesChanged: Void, interfaceStrings: ToolListItemInterfaceStringsDomainModel, favoritedResourceModels: [FavoritedResourceDataModel]) -> AnyPublisher<[YourFavoritedToolDomainModel], Never> in
          
            let numberOfFavoritedTools: Int = self.favoritedResourcesRepository.getNumberOfFavoritedResources()
            
            let favoritedResources: [ResourceDataModel] = favoritedResourceModels
                .prefix(maxCount ?? numberOfFavoritedTools)
                .compactMap({
                    self.resourcesRepository.getCachedObject(id: $0.id)
                })
            
            let yourFavoritedTools: [YourFavoritedToolDomainModel] = favoritedResources
                .map({
                    YourFavoritedToolDomainModel(
                        interfaceStrings: interfaceStrings,
                        analyticsToolAbbreviation: $0.abbreviation,
                        dataModelId: $0.id,
                        bannerImageId: $0.attrBanner,
                        name: self.getTranslatedToolName.getToolName(resource: $0, translateInLanguage: translateInLanguage),
                        category: self.getTranslatedToolCategory.getTranslatedCategory(resource: $0, translateInLanguage: translateInLanguage),
                        isFavorited: true,
                        languageAvailability: nil
                    )
                })
            
            return Just(yourFavoritedTools)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
