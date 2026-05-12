//
//  GetPersonalizedToolsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 3/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetPersonalizedToolsUseCase {

    private let resourcesRepository: ResourcesRepository
    private let personalizedToolsRepository: PersonalizedToolsRepository
    private let getLanguageElseAppLanguage: GetLanguageElseAppLanguage
    private let getToolsListItems: GetToolsListItems
    private let localizationServices: LocalizationServicesInterface

    init(resourcesRepository: ResourcesRepository, personalizedToolsRepository: PersonalizedToolsRepository, getLanguageElseAppLanguage: GetLanguageElseAppLanguage, getToolsListItems: GetToolsListItems, localizationServices: LocalizationServicesInterface) {

        self.resourcesRepository = resourcesRepository
        self.personalizedToolsRepository = personalizedToolsRepository
        self.getLanguageElseAppLanguage = getLanguageElseAppLanguage
        self.getToolsListItems = getToolsListItems
        self.localizationServices = localizationServices
    }

    @MainActor func execute(appLanguage: AppLanguageDomainModel, country: LocalizationSettingsCountryDomainModel?, filterToolsByLanguage: ToolFilterLanguageDomainModel) -> AnyPublisher<ToolsResultDomainModel, Error> {
        
        let languageCode: String = getLanguageElseAppLanguage
            .getLanguageCode(
                languageId: filterToolsByLanguage.filterId,
                appLanguage: appLanguage
            )
        
        let countryIsoRegionCode: String? = {
            if let isoRegionCode = country?.isoRegionCode, !isoRegionCode.isEmpty {
                return isoRegionCode
            }
            return nil
        }()
        
        let hasCountry: Bool = countryIsoRegionCode != nil
        
        return Publishers.CombineLatest(
            personalizedToolsRepository
                .getPersonalizedToolsChanged(
                    requestPriority: .high,
                    country: countryIsoRegionCode,
                    language: languageCode
                ),
            resourcesRepository
                .observeCollectionChangesPublisher()
        )
        .flatMap { (personalizedToolsChanged, resourcesChanged) -> AnyPublisher<[ResourceDataModel], Error> in
            
            return AnyPublisher() {
                try await self.personalizedToolsRepository
                    .getPersistedPersonalizedTools(
                        country: countryIsoRegionCode,
                        language: languageCode,
                        resourceTypes: ResourceType.toolTypes
                    )
            }
        }
        .flatMap { (resources: [ResourceDataModel]) -> AnyPublisher<ToolsResultDomainModel, Error> in
            
            return self.getToolsListItems
                .mapToolsToListItemsPublisher(
                    tools: resources,
                    appLanguage: appLanguage,
                    languageIdForAvailabilityText: filterToolsByLanguage.filterId
                )
                .map { (tools: [ToolListItemDomainModel]) -> ToolsResultDomainModel in
                    
                    if self.shouldShowUnavailableState(hasCountry: hasCountry, tools: tools) {
                        return self.getToolsUnavailable(appLanguage: appLanguage)
                    }
                    
                    return ToolsResultDomainModel(
                        tools: tools,
                        unavailableStrings: nil
                    )
                }
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    private func getToolsUnavailable(appLanguage: AppLanguageDomainModel) -> ToolsResultDomainModel {

        let unavailableState = PersonalizedToolsUnavailableDomainModel(
            title: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "tools.personalizationUnavailable.title"),
            message: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "tools.personalizationUnavailable.message")
        )

        return ToolsResultDomainModel(
            tools: [],
            unavailableStrings: unavailableState
        )
    }

    private func shouldShowUnavailableState(hasCountry: Bool, tools: [ToolListItemDomainModel]) -> Bool {
        return !hasCountry && tools.isEmpty
    }
}
