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
    
    func getLessonsListPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[LessonListItemDomainModel], Never> {
        
        let appLanguageModel: LanguageModel? = languagesRepository.getLanguage(code: appLanguage)
        
        return resourcesRepository
            .getResourcesChangedPublisher()
            .flatMap({ (resourcesDidChange: Void) -> AnyPublisher<[LessonListItemDomainModel], Never> in
                
                let lessons: [ResourceModel] = self.resourcesRepository.getAllLessons(sorted: true)
                
                let lessonListItems: [LessonListItemDomainModel] = lessons.map { (resource: ResourceModel) in

                    let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel
                    
                    if let language = appLanguageModel {
                        toolLanguageAvailability = self.getTranslatedToolLanguageAvailability.getTranslatedLanguageAvailability(resource: resource, translateInLanguage: language)
                    }
                    else {
                        toolLanguageAvailability = ToolLanguageAvailabilityDomainModel(availabilityString: "", isAvailable: false)
                    }
                
                    return LessonListItemDomainModel(
                        analyticsToolName: resource.abbreviation,
                        availabilityInAppLanguage: toolLanguageAvailability,
                        bannerImageId: resource.attrBanner,
                        dataModelId: resource.id,
                        name: self.getTranslatedToolName.getToolName(resource: resource, translateInLanguage: appLanguage)
                    )
                }
                
                return Just(lessonListItems)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
