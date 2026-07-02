//
//  FeaturedLessonsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class FeaturedLessonsDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: FeaturedLessonsDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: FeaturedLessonsDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getFeaturedLessonsUseCase() -> GetFeaturedLessonsUseCase {
        return GetFeaturedLessonsUseCase(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            languagesRepository: core.dataLayer.getLanguagesRepository(),
            getTranslatedToolName: core.domainLayer.supporting.getTranslatedToolName(),
            getTranslatedToolLanguageAvailability: core.domainLayer.supporting.getTranslatedToolLanguageAvailability(),
            lessonProgressRepository: core.dataLayer.getUserLessonProgressRepository(),
            getLessonListItemProgress: core.domainLayer.supporting.getLessonListItemProgress()
        )
    }
}
