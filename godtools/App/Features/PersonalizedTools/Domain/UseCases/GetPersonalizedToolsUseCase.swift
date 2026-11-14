//
//  GetPersonalizedToolsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 3/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetPersonalizedToolsUseCase: Sendable {

    private let resourcesRepository: ResourcesRepository
    private let personalizedToolsRepository: PersonalizedToolsRepository
    private let getPersonalizedToolResources: GetPersonalizedToolResources
    private let getLanguageElseAppLanguage: GetLanguageElseAppLanguage
    private let getToolsListItems: GetToolsListItems
    private let localizationServices: LocalizationServicesInterface

    init(
        resourcesRepository: ResourcesRepository,
        personalizedToolsRepository: PersonalizedToolsRepository,
        getPersonalizedToolResources: GetPersonalizedToolResources,
        getLanguageElseAppLanguage: GetLanguageElseAppLanguage,
        getToolsListItems: GetToolsListItems,
        localizationServices: LocalizationServicesInterface
    ) {

        self.resourcesRepository = resourcesRepository
        self.personalizedToolsRepository = personalizedToolsRepository
        self.getPersonalizedToolResources = getPersonalizedToolResources
        self.getLanguageElseAppLanguage = getLanguageElseAppLanguage
        self.getToolsListItems = getToolsListItems
        self.localizationServices = localizationServices
    }

    @MainActor func execute(
        appLanguage: AppLanguageDomainModel,
        country: LocalizationSettingsCountryDomainModel?,
        filterToolsByCategory: ToolFilterCategoryDomainModel,
        filterByLanguageId: String?
    ) -> AnyPublisher<PersonalizedToolsDomainModel, Error> {
        
        let languageCode: String = getLanguageElseAppLanguage
            .getLanguageCode(
                languageId: filterByLanguageId,
                appLanguage: appLanguage
            )
        
        let countryIsoRegionCode: String? = country?.isoRegionCodeIfSelected
        
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
        .receive(on: DispatchQueue.global())
        .flatMap { (personalizedToolsChanged, resourcesChanged) -> AnyPublisher<[ResourceDataModel], Error> in
            
            return AnyPublisher() {

                let tools: [ResourceDataModel] = try await self.getPersonalizedToolResources
                    .getRankedElseDefaultOrderTools(
                        countryIsoRegionCode: countryIsoRegionCode,
                        languageCode: languageCode
                    )

                return self.filterTools(tools: tools, byCategory: filterToolsByCategory)
            }
        }
        .map { (resources: [ResourceDataModel]) in

            let tools: [ToolListItemDomainModel] = self.getToolsListItems
                .mapToolsToListItems(
                    tools: resources,
                    appLanguage: appLanguage,
                    languageIdForAvailabilityText: filterByLanguageId
                )

            let showsPersonalizationUnavailable: Bool = tools.isEmpty
            let unavailableStrings: PersonalizedToolsUnavailableDomainModel? = showsPersonalizationUnavailable ? self.getToolsUnavailable(appLanguage: appLanguage) : nil

            return PersonalizedToolsDomainModel(
                tools: tools,
                unavailableStrings: unavailableStrings
            )
        }
        .eraseToAnyPublisher()
    }

    private func filterTools(tools: [ResourceDataModel], byCategory category: ToolFilterCategoryDomainModel) -> [ResourceDataModel] {

        guard let categoryId = category.filterId else {
            return tools
        }

        return tools.filter { $0.attrCategory.caseInsensitiveCompare(categoryId) == .orderedSame }
    }

    private func getToolsUnavailable(appLanguage: AppLanguageDomainModel) -> PersonalizedToolsUnavailableDomainModel {

        let titleKey: String = LocalizableStringKeys.toolsPersonalizationUnavailableTitle.key
        let messageKey: String = LocalizableStringKeys.toolsPersonalizationUnavailableMessage.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                titleKey,
                messageKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return PersonalizedToolsUnavailableDomainModel(
            title: strings[titleKey] ?? "",
            message: strings[messageKey] ?? ""
        )
    }
}
