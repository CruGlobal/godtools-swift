//
//  GetYourFavoritedToolsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetYourFavoritedToolsUseCase {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    private let resourcesRepository: ResourcesRepository
    private let getTranslatedToolName: GetTranslatedToolName
    private let getTranslatedToolCategory: GetTranslatedToolCategory
    private let getToolListItemStrings: GetToolListItemStrings
    
    init(
        favoritedResourcesRepository: FavoritedResourcesRepository,
        resourcesRepository: ResourcesRepository,
        getTranslatedToolName: GetTranslatedToolName,
        getTranslatedToolCategory: GetTranslatedToolCategory,
        getToolListItemStrings: GetToolListItemStrings
    ) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.resourcesRepository = resourcesRepository
        self.getTranslatedToolName = getTranslatedToolName
        self.getTranslatedToolCategory = getTranslatedToolCategory
        self.getToolListItemStrings = getToolListItemStrings
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel, maxCount: Int?) -> AnyPublisher<[YourFavoritedToolDomainModel], Error> {
        
        let strings: ToolListItemStringsDomainModel = getToolListItemStrings.getStrings(appLanguage: appLanguage)
        
        return Publishers.CombineLatest(
            resourcesRepository
                .observeCollectionChangesPublisher(),
            favoritedResourcesRepository
                .observeCollectionChangesPublisher()
        )
        .receive(on: DispatchQueue.global())
        .flatMap { (resourcesChanged: Void, favoritedResourcesChanged: Void) -> AnyPublisher<[YourFavoritedToolDomainModel], Error> in
            
            return AnyPublisher() {
                try await self.asyncExecute(appLanguage: appLanguage, maxCount: maxCount, strings: strings)
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func asyncExecute(appLanguage: AppLanguageDomainModel, maxCount: Int?, strings: ToolListItemStringsDomainModel) async throws -> [YourFavoritedToolDomainModel] {
        
        let favoritedResources: [FavoritedResourceDataModel] = try await favoritedResourcesRepository.getFavoritedResourcesSortedByPosition()
        
        let numberOfFavoritedTools: Int = try self.favoritedResourcesRepository.getObjectCount()
        
        let prefixedFavoritedResources: [ResourceDataModel] = favoritedResources
            .prefix(maxCount ?? numberOfFavoritedTools)
            .compactMap {
                self.resourcesRepository.getResourceById(id: $0.id)
            }
        
        let yourFavoritedTools: [YourFavoritedToolDomainModel] = prefixedFavoritedResources
            .map {
                YourFavoritedToolDomainModel(
                    strings: strings,
                    analyticsToolAbbreviation: $0.abbreviation,
                    dataModelId: $0.id,
                    bannerImageId: $0.attrBanner,
                    name: self.getTranslatedToolName.getToolName(resource: $0, translateInLanguage: appLanguage),
                    category: self.getTranslatedToolCategory.getTranslatedCategory(resource: $0, translateInLanguage: appLanguage),
                    isFavorited: true,
                    languageAvailability: nil
                )
            }
        
        return yourFavoritedTools
    }
}
