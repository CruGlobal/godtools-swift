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
    private let coreDomainLayer: AppDomainLayerDependencies
    private let dataLayer: FeaturedLessonsDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies, dataLayer: FeaturedLessonsDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.coreDomainLayer = coreDomainLayer
        self.dataLayer = dataLayer
    }
    
    func getFeaturedLessonsUseCase() -> GetFeaturedLessonsUseCase {
        return GetFeaturedLessonsUseCase(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            getTranslatedToolName: coreDomainLayer.supporting.getTranslatedToolName(),
            getTranslatedToolLanguageAvailability: coreDomainLayer.supporting.getTranslatedToolLanguageAvailability(),
            lessonProgressRepository: coreDataLayer.getUserLessonProgressRepository(),
            getLessonListItemProgress: coreDomainLayer.supporting.getLessonListItemProgress()
        )
    }
}
