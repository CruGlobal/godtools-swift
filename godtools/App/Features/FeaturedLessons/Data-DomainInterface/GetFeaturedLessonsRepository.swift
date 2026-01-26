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
    private let getLessonListItemProgressRepository: GetLessonListItemProgressRepository
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, getTranslatedToolName: GetTranslatedToolName, getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability, getLessonListItemProgressRepository: GetLessonListItemProgressRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedToolName = getTranslatedToolName
        self.getTranslatedToolLanguageAvailability = getTranslatedToolLanguageAvailability
        self.getLessonListItemProgressRepository = getLessonListItemProgressRepository
    }
    
    @MainActor func getFeaturedLessonsPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[FeaturedLessonDomainModel], Error> {
            
        let appLanguageModel: LanguageDataModel? = languagesRepository.cache.getCachedLanguage(code: appLanguage)
        
        return Publishers.CombineLatest(
            resourcesRepository.persistence.observeCollectionChangesPublisher(),
            getLessonListItemProgressRepository
                .getLessonListItemProgressChanged()
                .setFailureType(to: Error.self)
        )
        .flatMap({ (resourcesChanged: Void, lessonProgressDidChange: Void) -> AnyPublisher<[FeaturedLessonDomainModel], Error> in
            
            return self.resourcesRepository
                .cache
                .getFeaturedLessonsPublisher(sorted: true)
                .map { (featuredLessonsDataModels: [ResourceDataModel]) in
                    
                    let featuredLessons: [FeaturedLessonDomainModel] = featuredLessonsDataModels.map { (resource: ResourceDataModel) in

                        let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel
                        
                        if let language = appLanguageModel {
                            toolLanguageAvailability = self.getTranslatedToolLanguageAvailability.getTranslatedLanguageAvailability(resource: resource, language: language, translateInLanguage: language)
                        }
                        else {
                            toolLanguageAvailability = ToolLanguageAvailabilityDomainModel(availabilityString: "", isAvailable: false)
                        }
                        
                        let lessonProgress = self.getLessonListItemProgressRepository.getLessonProgress(lesson: resource, appLanguage: appLanguage)
                        
                        let nameLanguageDirection: LanguageDirectionDomainModel
                        
                        if let filterLanguageModel = appLanguageModel {
                            nameLanguageDirection = filterLanguageModel.languageDirectionDomainModel
                        } else {
                            nameLanguageDirection = .leftToRight
                        }
                        
                        return FeaturedLessonDomainModel(
                            analyticsToolName: resource.abbreviation,
                            availabilityInAppLanguage: toolLanguageAvailability,
                            bannerImageId: resource.attrBanner,
                            dataModelId: resource.id,
                            name: self.getTranslatedToolName.getToolName(resource: resource, translateInLanguage: appLanguage),
                            nameLanguageDirection: nameLanguageDirection,
                            lessonProgress: lessonProgress
                        )
                    }
                    
                    return featuredLessons
                }
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
