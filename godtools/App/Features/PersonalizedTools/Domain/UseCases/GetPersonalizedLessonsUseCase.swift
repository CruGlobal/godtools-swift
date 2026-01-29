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

    @MainActor func execute(appLanguage: AppLanguageDomainModel, country: String?, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) -> AnyPublisher<[LessonListItemDomainModel], Never> {

        // TODO: - if there's no country, get all the tools
        guard let country = country else {
            return Just([]).eraseToAnyPublisher()
        }
        
        // TODO: - make sure language id/app language is actually  right
        let language = filterLessonsByLanguage?.languageId ?? appLanguage
        
        return Publishers.CombineLatest3(
            personalizedToolsRepository.getPersonalizedToolsChanged(reloadFromRemote: true, requestPriority: .high, country: country, language: language, resourceType: .lesson),
            resourcesRepository.persistence.observeCollectionChangesPublisher(),
            getLessonListItemProgressRepository.getLessonListItemProgressChanged()
        )
        .map({ (_, _, _) in

            let personalizedTools = self.personalizedToolsRepository.getPersonalizedTools(country: country, language: language, resourceType: .lesson)
            
            let resources = self.fetchResources(for: personalizedTools)
            
            return self.mapLessonsToListItems(lessons: resources, appLanguage: appLanguage, filterLessonsByLanguage: filterLessonsByLanguage)
            
        })
        .eraseToAnyPublisher()
    }

    private func fetchResources(for personalizedToolsDataModel: PersonalizedToolsDataModel?) -> [ResourceDataModel] {
        guard let personalizedToolsDataModel = personalizedToolsDataModel else { return [] }
        
        return personalizedToolsDataModel.resourceIds.compactMap { resourceId in
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
