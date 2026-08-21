//
//  GetLessonsListItems.swift
//  godtools
//
//  Created by Levi Eggert on 2/5/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetLessonsListItems: Sendable {
    
    private let languagesRepository: LanguagesRepository
    private let getTranslatedToolName: GetTranslatedToolName
    private let getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability
    private let getLessonListItemProgress: GetLessonListItemProgress

    init(
        languagesRepository: LanguagesRepository,
        getTranslatedToolName: GetTranslatedToolName,
        getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability,
        getLessonListItemProgress: GetLessonListItemProgress
    ) {
        
        self.languagesRepository = languagesRepository
        self.getTranslatedToolName = getTranslatedToolName
        self.getTranslatedToolLanguageAvailability = getTranslatedToolLanguageAvailability
        self.getLessonListItemProgress = getLessonListItemProgress
    }
    
    func mapLessonsToListItems(
        lessons: [ResourceDataModel],
        appLanguage: AppLanguageDomainModel,
        filterLessonsByLanguage: LessonFilterLanguageDomainModel?
    ) async throws -> [LessonListItemDomainModel] {
        
        var lessonList: [LessonListItemDomainModel] = Array()

        for resource in lessons {
            
            let filterLanguageModel: LanguageDataModel?
            if let filterLanguageId = filterLessonsByLanguage?.languageId {
                filterLanguageModel = languagesRepository.getLanguageById(id: filterLanguageId)
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

            let lessonProgress = try await getLessonListItemProgress.getLessonProgress(
                lesson: resource,
                appLanguage: appLanguage
            )

            let nameLanguageDirection: LanguageDirectionDomainModel
            if let filterLanguageModel = filterLanguageModel {
                nameLanguageDirection = filterLanguageModel.languageDirectionDomainModel
            } else {
                nameLanguageDirection = .leftToRight
            }

            let item = LessonListItemDomainModel(
                analyticsToolName: resource.abbreviation,
                availabilityInAppLanguage: toolLanguageAvailability,
                bannerImageId: resource.attrBanner,
                dataModelId: resource.id,
                name: lessonName,
                nameLanguageDirection: nameLanguageDirection,
                lessonProgress: lessonProgress
            )
            
            lessonList.append(item)
        }
        
        return lessonList
    }
    
    private func getToolLanguageAvailability(
        appLanguage: AppLanguageDomainModel,
        filterLanguageModel: LanguageDataModel?,
        resource: ResourceDataModel
    ) -> ToolLanguageAvailabilityDomainModel {

        if let appLanguageModel = languagesRepository.getLanguageByCode(code: appLanguage) {
            
            let language: LanguageDataModel
            
            if let filterLanguageModel = filterLanguageModel {
                language = filterLanguageModel
            } else {
                language = appLanguageModel
            }
            
            return getTranslatedToolLanguageAvailability.getTranslatedLanguageAvailability(
                resource: resource,
                language: language,
                translateInLanguage: appLanguageModel
            )
        }
        else {
            return ToolLanguageAvailabilityDomainModel(availabilityString: "", isAvailable: false)
        }
    }
}
