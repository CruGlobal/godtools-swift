//
//  GetPersonalizedLessonsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 1/23/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetPersonalizedLessonsUseCase: Sendable {

    private let resourcesRepository: ResourcesRepository
    private let personalizedToolsRepository: PersonalizedToolsRepository
    private let getLanguageElseAppLanguage: GetLanguageElseAppLanguage
    private let lessonProgressRepository: UserLessonProgressRepository
    private let getLessonsListItems: GetLessonsListItems
    private let localizationServices: LocalizationServicesInterface

    init(
        resourcesRepository: ResourcesRepository,
        personalizedToolsRepository: PersonalizedToolsRepository,
        getLanguageElseAppLanguage: GetLanguageElseAppLanguage,
        lessonProgressRepository: UserLessonProgressRepository,
        getLessonsListItems: GetLessonsListItems,
        localizationServices: LocalizationServicesInterface
    ) {

        self.resourcesRepository = resourcesRepository
        self.personalizedToolsRepository = personalizedToolsRepository
        self.getLanguageElseAppLanguage = getLanguageElseAppLanguage
        self.lessonProgressRepository = lessonProgressRepository
        self.getLessonsListItems = getLessonsListItems
        self.localizationServices = localizationServices
    }

    @MainActor func execute(
        appLanguage: AppLanguageDomainModel,
        country: LocalizationSettingsCountryDomainModel?,
        filterLessonsByLanguage: LessonFilterLanguageDomainModel?
    ) -> AnyPublisher<PersonalizedLessonsDomainModel, Error> {

        let languageCode: String = getLanguageElseAppLanguage.getLanguageCode(languageId: filterLessonsByLanguage?.languageId, appLanguage: appLanguage)

        let countryIsoRegionCode: String? = {
            if let isoRegionCode = country?.isoRegionCode, !isoRegionCode.isEmpty {
                return isoRegionCode
            }
            return nil
        }()

        return getPersonalizedLessonsPublisher(
            countryIsoRegionCode: countryIsoRegionCode,
            languageCode: languageCode,
            appLanguage: appLanguage,
            filterLessonsByLanguage: filterLessonsByLanguage,
            hasCountry: countryIsoRegionCode != nil
        )
    }

    @MainActor private func getPersonalizedLessonsPublisher(countryIsoRegionCode: String?, languageCode: String, appLanguage: AppLanguageDomainModel, filterLessonsByLanguage: LessonFilterLanguageDomainModel?, hasCountry: Bool) -> AnyPublisher<PersonalizedLessonsDomainModel, Error> {

        return Publishers.CombineLatest3(
            personalizedToolsRepository
                .getPersonalizedToolsChanged(
                    requestPriority: .high,
                    country: countryIsoRegionCode,
                    language: languageCode
                ),
            resourcesRepository
                .observeCollectionChangesPublisher(),
            lessonProgressRepository
                .getLessonProgressChangedPublisher()
        )
        .receive(on: DispatchQueue.global())
        .flatMap({ (personalizedLessonsChanged, resourcesChanged, lessonProgressChanged) -> AnyPublisher<[ResourceDataModel], Error> in

            return AnyPublisher() {
                try await self.personalizedToolsRepository
                    .getTools(
                        requestPriority: .high,
                        type: self.getPersonalizedToolsType(countryIsoRegionCode: countryIsoRegionCode, languageCode: languageCode),
                        resourceTypes: [.lesson],
                        sortByResponse: true
                    )
            }
        })
        .tryMap { (resources: [ResourceDataModel]) in
            
            let lessons = try self.getLessonsListItems.mapLessonsToListItems(
                lessons: resources,
                appLanguage: appLanguage,
                filterLessonsByLanguage: filterLessonsByLanguage
            )

            let showsPersonalizationUnavailable: Bool = !hasCountry && lessons.isEmpty
            let unavailableStrings: PersonalizedLessonsUnavailableDomainModel? = showsPersonalizationUnavailable ? self.getLessonsUnavailable(appLanguage: appLanguage) : nil

            return PersonalizedLessonsDomainModel(
                lessons: lessons,
                unavailableStrings: unavailableStrings
            )
        }
        .eraseToAnyPublisher()
    }
    
    private func getPersonalizedToolsType(
        countryIsoRegionCode: String?,
        languageCode: String
    ) -> PersonalizedToolsType {

        guard let countryIsoRegionCode = countryIsoRegionCode else {
            return .defaultOrder(language: languageCode)
        }

        return .ranked(country: countryIsoRegionCode, language: languageCode)
    }

    private func getLessonsUnavailable(appLanguage: AppLanguageDomainModel) -> PersonalizedLessonsUnavailableDomainModel {

        let titleKey: String = LocalizableStringKeys.lessonsPersonalizationUnavailableTitle.key
        let messageKey: String = LocalizableStringKeys.lessonsPersonalizationUnavailableMessage.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                titleKey,
                messageKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return PersonalizedLessonsUnavailableDomainModel(
            title: strings[titleKey] ?? "",
            message: strings[messageKey] ?? ""
        )
    }
}
