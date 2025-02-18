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
    private let getLessonListItemProgressRepository: GetLessonListItemProgressRepository

    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, getTranslatedToolName: GetTranslatedToolName, getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability, getLessonListItemProgressRepository: GetLessonListItemProgressRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedToolName = getTranslatedToolName
        self.getTranslatedToolLanguageAvailability = getTranslatedToolLanguageAvailability
        self.getLessonListItemProgressRepository = getLessonListItemProgressRepository
    }
    
    func getLessonsListPublisher(appLanguage: AppLanguageDomainModel, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) -> AnyPublisher<[LessonListItemDomainModel], Never> {
                
        return Publishers.CombineLatest(
            resourcesRepository.getResourcesChangedPublisher(),
            getLessonListItemProgressRepository.getLessonListItemProgressChanged()
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
                
                let lessonProgress: LessonListItemProgressDomainModel = self.getLessonListItemProgressRepository.getLessonProgress(lesson: resource, appLanguage: appLanguage)
                
                let nameLanguageDirection: LanguageDirectionDomainModel
                if let filterLanguageModel = filterLanguageModel {
                    nameLanguageDirection = LanguageDirectionDomainModel(languageModel: filterLanguageModel)
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
