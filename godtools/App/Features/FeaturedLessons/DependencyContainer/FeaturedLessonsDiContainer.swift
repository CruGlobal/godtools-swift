//
//  FeaturedLessonsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class FeaturedLessonsDiContainer {
    
    let dataLayer: FeaturedLessonsDataLayerDependencies
    let domainLayer: FeaturedLessonsDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, appLanguageFeatureDomainLayer: AppLanguageFeatureDomainLayerDependencies, lessonsFeatureDomainLayer: LessonsFeatureDomainLayerDependencies) {
        
        dataLayer = FeaturedLessonsDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = FeaturedLessonsDomainLayerDependencies(dataLayer: dataLayer, appLanguageFeatureDomainLayer: appLanguageFeatureDomainLayer, lessonsFeatureDomainLayer: lessonsFeatureDomainLayer)
    }
}
