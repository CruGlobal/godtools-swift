//
//  GetYourFavoritedToolsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetYourFavoritedToolsUseCase: Sendable {
    
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

        return Publishers.CombineLatest(
            resourcesRepository
                .observeCollectionChangesPublisher(),
            favoritedResourcesRepository
                .observeCollectionChangesPublisher()
        )
        .receive(on: DispatchQueue.global())
        .flatMap { (resourcesChanged: Void, favoritedResourcesChanged: Void) -> AnyPublisher<[YourFavoritedToolDomainModel], Error> in

            return AnyPublisher() {
                try await self.asyncExecute(appLanguage: appLanguage, maxCount: maxCount)
            }
        }
        .eraseToAnyPublisher()
    }

    private func asyncExecute(
        appLanguage: AppLanguageDomainModel,
        maxCount: Int?
    ) async throws -> [YourFavoritedToolDomainModel] {

        let strings: ToolListItemStringsDomainModel = getToolListItemStrings.getStrings(appLanguage: appLanguage)

        let favoritedResources: [FavoritedResourceDataModel] = try await favoritedResourcesRepository.getFavoritedResourcesSortedByPosition()

        let numberOfFavoritedTools: Int = try favoritedResourcesRepository.getObjectCount()

        let prefixedFavoritedResources: [ResourceDataModel] = favoritedResources
            .prefix(maxCount ?? numberOfFavoritedTools)
            .compactMap {
                resourcesRepository.getResourceById(id: $0.id)
            }

        var yourFavoritedTools: [YourFavoritedToolDomainModel] = Array()

        for resource in prefixedFavoritedResources {

            yourFavoritedTools.append(
                YourFavoritedToolDomainModel(
                    strings: strings,
                    analyticsToolAbbreviation: resource.abbreviation,
                    dataModelId: resource.id,
                    bannerImageId: resource.attrBanner,
                    name: getTranslatedToolName.getToolName(resource: resource, translateInLanguage: appLanguage),
                    category: getTranslatedToolCategory.getTranslatedCategory(resource: resource, translateInLanguage: appLanguage),
                    isFavorited: true,
                    languageAvailability: nil
                )
            )
        }

        return yourFavoritedTools
    }
}
