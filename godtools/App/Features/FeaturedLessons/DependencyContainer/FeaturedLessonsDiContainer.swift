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
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = FeaturedLessonsDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = FeaturedLessonsDomainLayerDependencies(dataLayer: dataLayer)
    }
}
