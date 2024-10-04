//
//  GetFeaturedLessonsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetFeaturedLessonsRepository: GetFeaturedLessonsRepositoryInterface {
    
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
    
    func getFeaturedLessonsPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[FeaturedLessonDomainModel], Never> {
        
        let appLanguageModel: LanguageModel? = languagesRepository.getLanguage(code: appLanguage)
        
        return resourcesRepository.getResourcesChangedPublisher()
            .flatMap({ (resourcesChanged: Void) -> AnyPublisher<[FeaturedLessonDomainModel], Never> in
                
                let featuredLessonsDataModels: [ResourceModel] = self.resourcesRepository.getFeaturedLessons(sorted: true)
                
                let featuredLessons: [FeaturedLessonDomainModel] = featuredLessonsDataModels.map { (resource: ResourceModel) in

                    let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel
                    
                    if let language = appLanguageModel {
                        toolLanguageAvailability = self.getTranslatedToolLanguageAvailability.getTranslatedLanguageAvailability(resource: resource, language: language, translateInLanguage: language)
                    }
                    else {
                        toolLanguageAvailability = ToolLanguageAvailabilityDomainModel(availabilityString: "", isAvailable: false)
                    }
                    
                    return FeaturedLessonDomainModel(
                        analyticsToolName: resource.abbreviation,
                        availabilityInAppLanguage: toolLanguageAvailability,
                        bannerImageId: resource.attrBanner,
                        dataModelId: resource.id,
                        name: self.getTranslatedToolName.getToolName(resource: resource, translateInLanguage: appLanguage),
                        lessonProgress: LessonListItemProgressDomainModel.hiddenProgessDomainModel()
                    )
                }
                
                return Just(featuredLessons)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
