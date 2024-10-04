//
//  GetLessonsListRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLessonsListRepository: GetLessonsListRepositoryInterface {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let getTranslatedToolName: GetTranslatedToolName
    private let getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability
    private let lessonProgressRepository: UserLessonProgressRepository
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, getTranslatedToolName: GetTranslatedToolName, getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability, lessonProgressRepository: UserLessonProgressRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedToolName = getTranslatedToolName
        self.getTranslatedToolLanguageAvailability = getTranslatedToolLanguageAvailability
        self.lessonProgressRepository = lessonProgressRepository
    }
    
    func getLessonsListPublisher(appLanguage: AppLanguageDomainModel, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) -> AnyPublisher<[LessonListItemDomainModel], Never> {
                
        return Publishers.CombineLatest(
            resourcesRepository.getResourcesChangedPublisher(),
            lessonProgressRepository.getLessonProgressChangedPublisher()
        )
        .flatMap({ (resourcesDidChange: Void, lessonProgressDidChange: Void) -> AnyPublisher<[LessonListItemDomainModel], Never> in
            
            let lessons: [ResourceModel] = self.resourcesRepository.getAllLessons(filterByLanguageId: filterLessonsByLanguage?.languageId, sorted: true)
            
            let lessonListItems: [LessonListItemDomainModel] = lessons.map { (resource: ResourceModel) in
                
                let filterLanguageModel: LanguageModel?
                if let filterLanguageId = filterLessonsByLanguage?.languageId {
                    
                    filterLanguageModel = self.languagesRepository.getLanguage(id: filterLanguageId)
                } else {
                    filterLanguageModel = nil
                }
                
                let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel = self.getToolLanguageAvailability(appLanguage: appLanguage, filterLanguageModel: filterLanguageModel, resource: resource)
                let lessonName: String = self.getTranslatedToolName.getToolName(resource: resource, translateInLanguage: filterLanguageModel?.code ?? appLanguage)
                
                let lessonProgress: LessonListItemProgressDomainModel
                if let progress = self.lessonProgressRepository.getLessonProgress(lessonId: resource.id)?.progress {
                    lessonProgress = LessonListItemProgressDomainModel(shouldShowLessonProgress: true, completionProgress: progress, progressString: "\(Int(progress*100))% Complete")
                } else {
                    lessonProgress = LessonListItemProgressDomainModel.hiddenProgessDomainModel()
                }
                
                return LessonListItemDomainModel(
                    analyticsToolName: resource.abbreviation,
                    availabilityInAppLanguage: toolLanguageAvailability,
                    bannerImageId: resource.attrBanner,
                    dataModelId: resource.id,
                    name: lessonName,
                    lessonProgress: lessonProgress
                )
            }
            
            return Just(lessonListItems)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()

    }
}

extension GetLessonsListRepository {
    
    private func getToolLanguageAvailability(appLanguage: AppLanguageDomainModel, filterLanguageModel: LanguageModel?, resource: ResourceModel) -> ToolLanguageAvailabilityDomainModel {

        if let appLanguageModel = languagesRepository.getLanguage(code: appLanguage) {
            
            let language: LanguageModel
            
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
