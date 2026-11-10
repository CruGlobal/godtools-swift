//
//  GetPersonalizedToolFilterCategoriesUseCase.swift
//  godtools
//
//  Created by Jason Bennett on 11/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetPersonalizedToolFilterCategoriesUseCase: Sendable {

    private let resourcesRepository: ResourcesRepository
    private let personalizedToolsRepository: PersonalizedToolsRepository
    private let getPersonalizedToolResources: GetPersonalizedToolResources
    private let getLanguageElseAppLanguage: GetLanguageElseAppLanguage
    private let getToolFilterCategory: GetToolFilterCategory

    init(
        resourcesRepository: ResourcesRepository,
        personalizedToolsRepository: PersonalizedToolsRepository,
        getPersonalizedToolResources: GetPersonalizedToolResources,
        getLanguageElseAppLanguage: GetLanguageElseAppLanguage,
        getToolFilterCategory: GetToolFilterCategory
    ) {

        self.resourcesRepository = resourcesRepository
        self.personalizedToolsRepository = personalizedToolsRepository
        self.getPersonalizedToolResources = getPersonalizedToolResources
        self.getLanguageElseAppLanguage = getLanguageElseAppLanguage
        self.getToolFilterCategory = getToolFilterCategory
    }

    @MainActor func execute(
        appLanguage: AppLanguageDomainModel,
        country: LocalizationSettingsCountryDomainModel?,
        filterByLanguageId: String?
    ) -> AnyPublisher<[ToolFilterCategoryDomainModel], Error> {

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
        .flatMap { (personalizedToolsChanged, resourcesChanged) -> AnyPublisher<[ToolFilterCategoryDomainModel], Error> in

            return AnyPublisher() {

                let tools: [ResourceDataModel] = try await self.getPersonalizedToolResources
                    .getRankedElseDefaultOrderTools(
                        countryIsoRegionCode: countryIsoRegionCode,
                        languageCode: languageCode
                    )

                return self.getToolFilterCategory.createCategoryFilters(
                    from: tools,
                    translatedInAppLanguage: appLanguage
                )
            }
        }
        .eraseToAnyPublisher()
    }
}
