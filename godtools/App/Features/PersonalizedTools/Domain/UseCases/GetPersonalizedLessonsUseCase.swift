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
    private let languagesRepository: LanguagesRepository
    private let lessonProgressRepository: UserLessonProgressRepository
    private let getLessonsListItems: GetLessonsListItems

    init(resourcesRepository: ResourcesRepository, personalizedLessonsRepository: PersonalizedLessonsRepository, languagesRepository: LanguagesRepository, lessonProgressRepository: UserLessonProgressRepository, getLessonsListItems: GetLessonsListItems) {

        self.resourcesRepository = resourcesRepository
        self.personalizedLessonsRepository = personalizedLessonsRepository
        self.languagesRepository = languagesRepository
        self.lessonProgressRepository = lessonProgressRepository
        self.getLessonsListItems = getLessonsListItems
    }

    @MainActor func execute(appLanguage: AppLanguageDomainModel, country: LocalizationSettingsCountryDomainModel?, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) -> AnyPublisher<[LessonListItemDomainModel], Error> {

        let countryIsoRegionCode: String? = {
            if let isoRegionCode = country?.isoRegionCode, !isoRegionCode.isEmpty {
                return isoRegionCode
            }
            return nil
        }()

        return getPersonalizedLessonsPublisher(countryIsoRegionCode: countryIsoRegionCode, appLanguage: appLanguage, filterLessonsByLanguage: filterLessonsByLanguage)
    }
    
    @MainActor private func getPersonalizedLessonsPublisher(countryIsoRegionCode: String?, appLanguage: AppLanguageDomainModel, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) -> AnyPublisher<[LessonListItemDomainModel], Error> {

        let language = getLanguageCode(filterLessonsByLanguage: filterLessonsByLanguage, appLanguage: appLanguage)

        return Publishers.CombineLatest3(
            personalizedLessonsRepository
                .getPersonalizedLessonsChanged(reloadFromRemote: true, requestPriority: .high, country: countryIsoRegionCode, language: language)
                .setFailureType(to: Error.self),
            resourcesRepository.persistence
                .observeCollectionChangesPublisher(),
            lessonProgressRepository
                .getLessonProgressChangedPublisher()
                .setFailureType(to: Error.self)
        )
        .flatMap({ (personalizedLessonsChanged, resourcesChanged, lessonProgressChanged) in

            let personalizedLessons = self.personalizedLessonsRepository.getPersonalizedLessons(
                country: countryIsoRegionCode,
                language: language
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
    
    private func getLanguageCode(filterLessonsByLanguage: LessonFilterLanguageDomainModel?, appLanguage: AppLanguageDomainModel) -> BCP47LanguageIdentifier {
        
        let languageCode: BCP47LanguageIdentifier
        
        if let filterLanguageId = filterLessonsByLanguage?.languageId,
           let filterLanguage = languagesRepository.persistence.getDataModelNonThrowing(id: filterLanguageId) {
            
            languageCode = filterLanguage.code
            
        } else {
            languageCode = appLanguage
        }
        
        return languageCode
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
