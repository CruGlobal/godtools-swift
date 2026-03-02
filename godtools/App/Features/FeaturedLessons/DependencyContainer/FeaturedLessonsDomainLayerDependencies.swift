//
//  FeaturedLessonsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class FeaturedLessonsDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: FeaturedLessonsDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: FeaturedLessonsDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }
    
    func getFeaturedLessonsUseCase() -> GetFeaturedLessonsUseCase {
        return GetFeaturedLessonsUseCase(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            getTranslatedToolName: coreDataLayer.getTranslatedToolName(),
            getTranslatedToolLanguageAvailability: coreDataLayer.getTranslatedToolLanguageAvailability(),
            lessonProgressRepository: coreDataLayer.getUserLessonProgressRepository(),
            getLessonListItemProgressRepository: coreDataLayer.getLessonListItemProgressRepository()
        )
    }
}
