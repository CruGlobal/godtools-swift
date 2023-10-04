//
//  FeaturedLessonsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class FeaturedLessonsDomainLayerDependencies {
    
    private let dataLayer: FeaturedLessonsDataLayerDependencies
    private let appLanguageFeatureDomainLayer: AppLanguageFeatureDomainLayerDependencies
    private let lessonsFeatureDomainLayer: LessonsFeatureDomainLayerDependencies
    
    init(dataLayer: FeaturedLessonsDataLayerDependencies, appLanguageFeatureDomainLayer: AppLanguageFeatureDomainLayerDependencies, lessonsFeatureDomainLayer: LessonsFeatureDomainLayerDependencies) {
        
        self.dataLayer = dataLayer
        self.appLanguageFeatureDomainLayer = appLanguageFeatureDomainLayer
        self.lessonsFeatureDomainLayer = lessonsFeatureDomainLayer
    }
    
    func getFeaturedLessonsUseCase() -> GetFeaturedLessonsUseCase {
        
        return GetFeaturedLessonsUseCase(
            getCurrentAppLanguageUseCase: appLanguageFeatureDomainLayer.getCurrentAppLanguageUseCase(),
            getFeaturedLessonsRepositoryInterface: dataLayer.getFeaturedLessonsRepositoryInterface(),
            getLessonNameInAppLanguageUseCase: lessonsFeatureDomainLayer.getLessonNameInAppLanguageUseCase(),
            getLessonAvailabilityInAppLanguageUseCase: lessonsFeatureDomainLayer.getLessonAvailabilityInAppLanguageUseCase()
        )
    }
}
