//
//  GetPersonalizedLessonsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 1/23/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

class GetPersonalizedLessonsUseCase {

    private let resourcesRepository: ResourcesRepository
    private let personalizedToolsRepository: PersonalizedToolsRepository
    private let getLanguageElseAppLanguage: GetLanguageElseAppLanguage
    private let lessonProgressRepository: UserLessonProgressRepository
    private let getLessonsListItems: GetLessonsListItems
    private let localizationServices: LocalizationServicesInterface

    init(resourcesRepository: ResourcesRepository, personalizedToolsRepository: PersonalizedToolsRepository, getLanguageElseAppLanguage: GetLanguageElseAppLanguage, lessonProgressRepository: UserLessonProgressRepository, getLessonsListItems: GetLessonsListItems, localizationServices: LocalizationServicesInterface) {

        self.resourcesRepository = resourcesRepository
        self.personalizedToolsRepository = personalizedToolsRepository
        self.getLanguageElseAppLanguage = getLanguageElseAppLanguage
        self.lessonProgressRepository = lessonProgressRepository
        self.getLessonsListItems = getLessonsListItems
        self.localizationServices = localizationServices
    }

    @MainActor func execute(appLanguage: AppLanguageDomainModel, country: LocalizationSettingsCountryDomainModel?, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) -> AnyPublisher<LessonsResultDomainModel, Error> {

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

    @MainActor private func getPersonalizedLessonsPublisher(countryIsoRegionCode: String?, languageCode: String, appLanguage: AppLanguageDomainModel, filterLessonsByLanguage: LessonFilterLanguageDomainModel?, hasCountry: Bool) -> AnyPublisher<LessonsResultDomainModel, Error> {

        return Publishers.CombineLatest3(
            personalizedToolsRepository
                .getPersonalizedToolsChanged(requestPriority: .high, country: countryIsoRegionCode, language: languageCode),
            resourcesRepository.persistence
                .observeCollectionChangesPublisher(),
            lessonProgressRepository
                .getLessonProgressChangedPublisher()
                .setFailureType(to: Error.self)
        )
        .flatMap({ (personalizedToolsChanged, resourcesChanged, lessonProgressChanged) -> AnyPublisher<[ResourceDataModel], Error> in

            return self.personalizedToolsRepository
                .getPersistedPersonalizedToolsPublisher(
                    country: countryIsoRegionCode,
                    language: languageCode,
                    resourceTypes: [.lesson]
                )
        })
        .tryMap { (resources: [ResourceDataModel]) in

            let lessons = try self.getLessonsListItems.mapLessonsToListItems(
                lessons: resources,
                appLanguage: appLanguage,
                filterLessonsByLanguage: filterLessonsByLanguage
            )

            if self.shouldShowUnavailableState(hasCountry: hasCountry, lessons: lessons) {
                return self.getLessonsUnavailable(appLanguage: appLanguage)
            }

            return LessonsResultDomainModel(
                lessons: lessons,
                unavailableStrings: nil
            )
        }
        .eraseToAnyPublisher()
    }
    
    private func getLessonsUnavailable(appLanguage: AppLanguageDomainModel) -> LessonsResultDomainModel {

        let unavailableState = PersonalizedLessonsUnavailableDomainModel(
            title: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "lessons.personalizationUnavailable.title"),
            message: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "lessons.personalizationUnavailable.message")
        )

        return LessonsResultDomainModel(
            lessons: [],
            unavailableStrings: unavailableState
        )
    }

    private func shouldShowUnavailableState(hasCountry: Bool, lessons: [LessonListItemDomainModel]) -> Bool {
        return !hasCountry && lessons.isEmpty
    }
}
