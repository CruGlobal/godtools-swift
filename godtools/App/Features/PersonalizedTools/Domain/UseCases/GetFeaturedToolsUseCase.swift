//
//  GetFeaturedToolsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetFeaturedToolsUseCase: Sendable {
        
    private let resourcesRepository: ResourcesRepository
    private let personalizedToolsRepository: PersonalizedToolsRepository
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let getTranslatedToolName: GetTranslatedToolName
    private let getTranslatedToolCategory: GetTranslatedToolCategory
    private let getToolListItemStrings: GetToolListItemStrings
    private let getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability
    
    init(
        resourcesRepository: ResourcesRepository,
        personalizedToolsRepository: PersonalizedToolsRepository,
        favoritedResourcesRepository: FavoritedResourcesRepository,
        languagesRepository: LanguagesRepository,
        getTranslatedToolName: GetTranslatedToolName,
        getTranslatedToolCategory: GetTranslatedToolCategory,
        getToolListItemStrings: GetToolListItemStrings,
        getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability
    ) {
        
        self.resourcesRepository = resourcesRepository
        self.personalizedToolsRepository = personalizedToolsRepository
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedToolName = getTranslatedToolName
        self.getTranslatedToolCategory = getTranslatedToolCategory
        self.getToolListItemStrings = getToolListItemStrings
        self.getTranslatedToolLanguageAvailability = getTranslatedToolLanguageAvailability
    }
    
    @MainActor func execute(
        appLanguage: AppLanguageDomainModel,
        country: LocalizationSettingsCountryDomainModel?
    ) -> AnyPublisher<[FeaturedToolListItemDomainModel], Error> {

        guard let countryIsoRegionCode = country?.isoRegionCodeIfSelected else {

            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return Publishers.CombineLatest(
            personalizedToolsRepository
                .getPersonalizedToolsChanged(
                    requestPriority: .high,
                    country: countryIsoRegionCode,
                    language: appLanguage
                ),
            resourcesRepository
                .observeCollectionChangesPublisher()
        )
        .receive(on: DispatchQueue.global())
        .flatMap({ (personalizedToolsChanged: Void, resourcesChanged: Void) -> AnyPublisher<[FeaturedToolListItemDomainModel], Error> in

            return AnyPublisher() {
                try await self.getFeaturedTools(
                    appLanguage: appLanguage,
                    countryIsoRegionCode: countryIsoRegionCode
                )
            }
        })
        .eraseToAnyPublisher()
    }
    
    private func getFeaturedTools(
        appLanguage: AppLanguageDomainModel,
        countryIsoRegionCode: String
    ) async throws -> [FeaturedToolListItemDomainModel] {

        let languageForAvailabilityTextModel: LanguageDataModel? = languagesRepository.getLanguageByCode(code: appLanguage)
        
        let strings: ToolListItemStringsDomainModel = getToolListItemStrings.getStrings(appLanguage: appLanguage)

        let featuredToolResources: [ResourceDataModel] = try await personalizedToolsRepository
            .getTools(
                requestPriority: .high,
                type: .featured(country: countryIsoRegionCode, language: appLanguage),
                resourceTypes: ResourceType.toolTypes,
                sortByResponse: true
            )
            .filter { !$0.isHidden }

        var featuredTools: [FeaturedToolListItemDomainModel] = Array()

        for resource in featuredToolResources {

            let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel

            if let language = languageForAvailabilityTextModel {

                toolLanguageAvailability = getTranslatedToolLanguageAvailability.getTranslatedLanguageAvailability(
                    resource: resource,
                    language: language,
                    translateInLanguage: appLanguage
                )
            }
            else {
                
                toolLanguageAvailability = ToolLanguageAvailabilityDomainModel(
                    availabilityString: "",
                    isAvailable: false
                )
            }

            featuredTools.append(
                FeaturedToolListItemDomainModel(
                    strings: strings,
                    analyticsToolAbbreviation: resource.abbreviation,
                    dataModelId: resource.id,
                    bannerImageId: resource.attrBanner,
                    name: getTranslatedToolName.getToolName(resource: resource, translateInLanguage: appLanguage),
                    category: getTranslatedToolCategory.getTranslatedCategory(resource: resource, translateInLanguage: appLanguage),
                    isFavorited: favoritedResourcesRepository.getResourceIsFavorited(id: resource.id),
                    languageAvailability: toolLanguageAvailability
                )
            )
        }

        return featuredTools
    }
}
