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
    private let getToolListItemInterfaceStringsRepository: GetToolListItemInterfaceStringsRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository, resourcesRepository: ResourcesRepository, getTranslatedToolName: GetTranslatedToolName, getTranslatedToolCategory: GetTranslatedToolCategory, getToolListItemInterfaceStringsRepository: GetToolListItemInterfaceStringsRepository) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.resourcesRepository = resourcesRepository
        self.getTranslatedToolName = getTranslatedToolName
        self.getTranslatedToolCategory = getTranslatedToolCategory
        self.getToolListItemInterfaceStringsRepository = getToolListItemInterfaceStringsRepository
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel, maxCount: Int?) -> AnyPublisher<[YourFavoritedToolDomainModel], Error> {
        
        return Publishers.CombineLatest3(
            resourcesRepository
                .persistence
                .observeCollectionChangesPublisher(),
            getToolListItemInterfaceStringsRepository
                .getStringsPublisher(translateInLanguage: appLanguage)
                .setFailureType(to: Error.self),
            favoritedResourcesRepository
                .persistence
                .observeCollectionChangesPublisher()
        )
        .flatMap { (resourcesChanged: Void, strings: ToolListItemInterfaceStringsDomainModel, favoritedResourcesChanged: Void) -> AnyPublisher<[YourFavoritedToolDomainModel], Error> in
            
            return self.favoritedResourcesRepository
                .getFavoritedResourcesSortedByPositionPublisher()
                .tryMap { (favoritedResources: [FavoritedResourceDataModel]) in
                    
                    return try self.mapToDomainModels(
                        appLanguage: appLanguage,
                        maxCount: maxCount,
                        strings: strings,
                        favoritedResources: favoritedResources
                    )
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    private func mapToDomainModels(appLanguage: AppLanguageDomainModel, maxCount: Int?, strings: ToolListItemInterfaceStringsDomainModel, favoritedResources: [FavoritedResourceDataModel]) throws -> [YourFavoritedToolDomainModel] {
        
        let numberOfFavoritedTools: Int = try self.favoritedResourcesRepository.persistence.getObjectCount()
        
        let prefixedFavoritedResources: [ResourceDataModel] = try favoritedResources
            .prefix(maxCount ?? numberOfFavoritedTools)
            .compactMap {
                try self.resourcesRepository.persistence.getDataModel(id: $0.id)
            }
        
        let yourFavoritedTools: [YourFavoritedToolDomainModel] = prefixedFavoritedResources
            .map {
                YourFavoritedToolDomainModel(
                    interfaceStrings: strings,
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
