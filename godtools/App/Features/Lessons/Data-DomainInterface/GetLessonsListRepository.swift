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
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, getTranslatedToolName: GetTranslatedToolName, getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedToolName = getTranslatedToolName
        self.getTranslatedToolLanguageAvailability = getTranslatedToolLanguageAvailability
    }
    
    func getLessonsListPublisher(appLanguage: AppLanguageDomainModel, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) -> AnyPublisher<[LessonListItemDomainModel], Never> {
        
        let appLanguageModel: LanguageModel? = languagesRepository.getLanguage(code: appLanguage)
        
        return resourcesRepository
            .getResourcesChangedPublisher()
            .flatMap({ (resourcesDidChange: Void) -> AnyPublisher<[LessonListItemDomainModel], Never> in
                
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
                
                    let randomProgress = [0.0, 0.2, 0.4, 0.5, 0.7, 0.9, 1.0].randomElement() ?? 0.0
                    return LessonListItemDomainModel(
                        analyticsToolName: resource.abbreviation,
                        availabilityInAppLanguage: toolLanguageAvailability,
                        bannerImageId: resource.attrBanner,
                        dataModelId: resource.id,
                        name: lessonName,
                        completionProgress: randomProgress,
                        completionString: "\(Int(randomProgress*100))% Complete"
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
