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
    private let getTranslatedToolName: GetTranslatedToolName
    private let getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability
    private let lessonProgressRepository: UserLessonProgressRepository
    private let getLessonListItemProgressRepository: GetLessonListItemProgressRepository

    init(resourcesRepository: ResourcesRepository, personalizedLessonsRepository: PersonalizedLessonsRepository, languagesRepository: LanguagesRepository, getTranslatedToolName: GetTranslatedToolName, getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability, lessonProgressRepository: UserLessonProgressRepository, getLessonListItemProgressRepository: GetLessonListItemProgressRepository) {

        self.resourcesRepository = resourcesRepository
        self.personalizedLessonsRepository = personalizedLessonsRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedToolName = getTranslatedToolName
        self.getTranslatedToolLanguageAvailability = getTranslatedToolLanguageAvailability
        self.lessonProgressRepository = lessonProgressRepository
        self.getLessonListItemProgressRepository = getLessonListItemProgressRepository
    }

    @MainActor func execute(appLanguage: AppLanguageDomainModel, country: LocalizationSettingsCountryDomainModel, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) -> AnyPublisher<[LessonListItemDomainModel], Error> {

        let language = getLanguageCode(filterLessonsByLanguage: filterLessonsByLanguage, appLanguage: appLanguage)

        return Publishers.CombineLatest3(
            personalizedLessonsRepository
                .getPersonalizedLessonsChanged(reloadFromRemote: true, requestPriority: .high, country: country.isoRegionCode, language: language)
                .setFailureType(to: Error.self),
            resourcesRepository.persistence
                .observeCollectionChangesPublisher(),
            lessonProgressRepository
                .getLessonProgressChangedPublisher()
                .setFailureType(to: Error.self)
        )
        .flatMap({ (_, _, _) in

            let personalizedLessons = self.personalizedLessonsRepository.getPersonalizedLessons(country: country.isoRegionCode, language: language)

            return self.fetchResources(for: personalizedLessons)
        })
        .map { resources in

            return self.mapLessonsToListItems(lessons: resources, appLanguage: appLanguage, filterLessonsByLanguage: filterLessonsByLanguage)
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

    private func mapLessonsToListItems(lessons: [ResourceDataModel], appLanguage: AppLanguageDomainModel, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) -> [LessonListItemDomainModel] {

        return lessons.map { resource in

            let filterLanguageModel: LanguageDataModel?
            if let filterLanguageId = filterLessonsByLanguage?.languageId {
                filterLanguageModel = languagesRepository.persistence.getDataModelNonThrowing(id: filterLanguageId)
            } else {
                filterLanguageModel = nil
            }

            let toolLanguageAvailability = getToolLanguageAvailability(
                appLanguage: appLanguage,
                filterLanguageModel: filterLanguageModel,
                resource: resource
            )

            let lessonName = getTranslatedToolName.getToolName(
                resource: resource,
                translateInLanguage: filterLanguageModel?.code ?? appLanguage
            )

            let lessonProgress = getLessonListItemProgressRepository.getLessonProgress(
                lesson: resource,
                appLanguage: appLanguage
            )

            let nameLanguageDirection: LanguageDirectionDomainModel
            if let filterLanguageModel = filterLanguageModel {
                nameLanguageDirection = filterLanguageModel.languageDirectionDomainModel
            } else {
                nameLanguageDirection = .leftToRight
            }

            return LessonListItemDomainModel(
                analyticsToolName: resource.abbreviation,
                availabilityInAppLanguage: toolLanguageAvailability,
                bannerImageId: resource.attrBanner,
                dataModelId: resource.id,
                name: lessonName,
                nameLanguageDirection: nameLanguageDirection,
                lessonProgress: lessonProgress
            )
        }
    }

    private func getToolLanguageAvailability(appLanguage: AppLanguageDomainModel, filterLanguageModel: LanguageDataModel?, resource: ResourceDataModel) -> ToolLanguageAvailabilityDomainModel {

        if let appLanguageModel = languagesRepository.cache.getCachedLanguage(code: appLanguage) {

            let language: LanguageDataModel

            if let filterLanguageModel = filterLanguageModel {
                language = filterLanguageModel
            } else {
                language = appLanguageModel
            }

            return self.getTranslatedToolLanguageAvailability.getTranslatedLanguageAvailability(resource: resource, language: language, translateInLanguage: appLanguageModel)
        }
        else {
            return ToolLanguageAvailabilityDomainModel(availabilityString: "", isAvailable: false)
        }
    }
}
