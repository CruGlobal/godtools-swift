//
//  FeaturedLessonsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class FeaturedLessonsDiContainer {
    
    let dataLayer: FeaturedLessonsDataLayerDependencies
    let domainLayer: FeaturedLessonsDomainLayerDependencies
    
    init(core: AppCoreDiContainer) {
        
        dataLayer = FeaturedLessonsDataLayerDependencies(coreDataLayer: core.dataLayer)
        domainLayer = FeaturedLessonsDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
