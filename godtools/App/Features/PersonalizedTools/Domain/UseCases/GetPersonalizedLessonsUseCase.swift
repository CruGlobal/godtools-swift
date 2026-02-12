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
    private let personalizedLessonsRepository: PersonalizedLessonsRepository
    private let getLanguageElseAppLanguage: GetLanguageElseAppLanguage
    private let lessonProgressRepository: UserLessonProgressRepository
    private let getLessonsListItems: GetLessonsListItems

    init(resourcesRepository: ResourcesRepository, personalizedLessonsRepository: PersonalizedLessonsRepository, getLanguageElseAppLanguage: GetLanguageElseAppLanguage, lessonProgressRepository: UserLessonProgressRepository, getLessonsListItems: GetLessonsListItems) {

        self.resourcesRepository = resourcesRepository
        self.personalizedLessonsRepository = personalizedLessonsRepository
        self.getLanguageElseAppLanguage = getLanguageElseAppLanguage
        self.lessonProgressRepository = lessonProgressRepository
        self.getLessonsListItems = getLessonsListItems
    }

    @MainActor func execute(appLanguage: AppLanguageDomainModel, country: LocalizationSettingsCountryDomainModel?, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) -> AnyPublisher<[LessonListItemDomainModel], Error> {

        let languageCode: String = getLanguageElseAppLanguage.getLanguageCode(languageId: filterLessonsByLanguage?.languageId, appLanguage: appLanguage)
        
        let countryIsoRegionCode: String? = country?.isoRegionCode
        
        // TODO: Remove this guard once supporting an optional country in this UseCase. ~Levi
        guard let countryIsoRegionCode = countryIsoRegionCode, !countryIsoRegionCode.isEmpty else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return Publishers.CombineLatest3(
            personalizedLessonsRepository
                .getPersonalizedLessonsChanged(reloadFromRemote: true, requestPriority: .high, country: countryIsoRegionCode, language: languageCode),
            resourcesRepository.persistence
                .observeCollectionChangesPublisher(),
            lessonProgressRepository
                .getLessonProgressChangedPublisher()
                .setFailureType(to: Error.self)
        )
        .flatMap({ (personalizedLessonsChanged, resourcesChanged, lessonProgressChanged) in

            let personalizedLessons = self.personalizedLessonsRepository.getPersonalizedLessons(
                country: countryIsoRegionCode,
                language: languageCode
            )

            return self.fetchResources(for: personalizedLessons)
        })
        .map { resources in

            return self.getLessonsListItems.mapLessonsToListItems(
                lessons: resources,
                appLanguage: appLanguage,
                filterLessonsByLanguage: filterLessonsByLanguage
            )
        }
        .eraseToAnyPublisher()
    }
    
    private func fetchResources(for personalizedLessonsDataModel: PersonalizedLessonsDataModel?) -> AnyPublisher<[ResourceDataModel], Error> {
        guard let personalizedLessonsDataModel = personalizedLessonsDataModel else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return resourcesRepository.persistence.getDataModelsPublisher(getOption: .objectsByIds(ids: personalizedLessonsDataModel.resourceIds))
    }
}
