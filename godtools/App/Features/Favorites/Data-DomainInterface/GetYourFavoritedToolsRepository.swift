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
    private let maxNumberOfYourFavoritedToolsToDisplay: Int = 5
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository, resourcesRepository: ResourcesRepository, getTranslatedToolName: GetTranslatedToolName, getTranslatedToolCategory: GetTranslatedToolCategory) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.resourcesRepository = resourcesRepository
        self.getTranslatedToolName = getTranslatedToolName
        self.getTranslatedToolCategory = getTranslatedToolCategory
    }
    
    func getToolsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<[YourFavoritedToolDomainModel], Never> {
        
        return Publishers.CombineLatest(
            favoritedResourcesRepository.getFavoritedResourcesChangedPublisher(),
            resourcesRepository.getResourcesChangedPublisher()
        )
        .flatMap({ (favoritedResourcesChanged: Void, resourcesChanged: Void) -> AnyPublisher<[YourFavoritedToolDomainModel], Never> in
          
            let favoritedResources: [ResourceModel] = self.favoritedResourcesRepository
                .getFavoritedResourcesSortedByCreatedAt(ascendingOrder: false)
                .prefix(self.maxNumberOfYourFavoritedToolsToDisplay)
                .compactMap({
                    self.resourcesRepository.getResource(id: $0.id)
                })
            
            let yourFavoritedTools: [YourFavoritedToolDomainModel] = favoritedResources
                .map({
                    YourFavoritedToolDomainModel(
                        analyticsToolAbbreviation: $0.abbreviation,
                        dataModelId: $0.id,
                        bannerImageId: $0.attrBanner,
                        name: self.getTranslatedToolName.getToolName(resource: $0, translateInLanguage: translateInLanguage),
                        category: self.getTranslatedToolCategory.getTranslatedCategory(resource: $0, translateInLanguage: translateInLanguage)
                    )
                })
            
            return Just(yourFavoritedTools)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
