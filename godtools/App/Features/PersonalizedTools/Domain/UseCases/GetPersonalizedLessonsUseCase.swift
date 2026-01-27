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
    private let languagesRepository: LanguagesRepository
    private let getTranslatedToolName: GetTranslatedToolName
    private let getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability
    private let getLessonListItemProgressRepository: GetLessonListItemProgressRepository

    init(resourcesRepository: ResourcesRepository, personalizedToolsRepository: PersonalizedToolsRepository, languagesRepository: LanguagesRepository, getTranslatedToolName: GetTranslatedToolName, getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability, getLessonListItemProgressRepository: GetLessonListItemProgressRepository) {

        self.resourcesRepository = resourcesRepository
        self.personalizedToolsRepository = personalizedToolsRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedToolName = getTranslatedToolName
        self.getTranslatedToolLanguageAvailability = getTranslatedToolLanguageAvailability
        self.getLessonListItemProgressRepository = getLessonListItemProgressRepository
    }

    func execute(appLanguage: AppLanguageDomainModel, country: String?, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) -> AnyPublisher<[LessonListItemDomainModel], Never> {

        // TODO: - if there's no country, get all the tools
        guard let country = country else {
            return Just([]).eraseToAnyPublisher()
        }
        
        // TODO: - listen for changes on personalizedToolsRepository
        return Publishers.CombineLatest(
            resourcesRepository.persistence.observeCollectionChangesPublisher(),
            getLessonListItemProgressRepository.getLessonListItemProgressChanged()
        )
        .flatMap({ (resourcesDidChange: Void, lessonProgressDidChange: Void) -> AnyPublisher<[LessonListItemDomainModel], Never> in

            return self.personalizedToolsRepository
                .getAllRankedResourcesPublisher(
                    requestPriority: .high,
                    country: country,
                    language: filterLessonsByLanguage?.languageId ?? appLanguage,
                    resourceType: .lesson
                )
                .catch { error -> AnyPublisher<[PersonalizedToolsDataModel], Never> in
                    return Just([])
                        .eraseToAnyPublisher()
                }
                .map { personalizedToolsDataModels -> [LessonListItemDomainModel] in

                    let resources = self.fetchResources(for: personalizedToolsDataModels)

                    return self.mapLessonsToListItems(
                        lessons: resources,
                        appLanguage: appLanguage,
                        filterLessonsByLanguage: filterLessonsByLanguage
                    )
                }
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }

    private func fetchResources(for personalizedToolsDataModels: [PersonalizedToolsDataModel]) -> [ResourceDataModel] {
        
        guard let firstDataModel = personalizedToolsDataModels.first(where: { !$0.resourceIds.isEmpty }) else {
            return []
        }
        
        return firstDataModel.resourceIds.compactMap { resourceId in
            resourcesRepository.persistence.getObject(id: resourceId)
        }
    }

    private func mapLessonsToListItems(lessons: [ResourceDataModel], appLanguage: AppLanguageDomainModel, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) -> [LessonListItemDomainModel] {

        return lessons.map { resource in

            let filterLanguageModel: LanguageDataModel?
            if let filterLanguageId = filterLessonsByLanguage?.languageId {
                filterLanguageModel = languagesRepository.persistence.getObject(id: filterLanguageId)
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
