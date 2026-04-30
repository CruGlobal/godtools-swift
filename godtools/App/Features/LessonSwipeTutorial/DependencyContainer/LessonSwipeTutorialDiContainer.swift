//
//  LessonSwipeTutorialDiContainer.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class LessonSwipeTutorialDiContainer {
    
    let dataLayer: LessonSwipeTutorialDataLayerDependencies
    let domainlayer: LessonSwipeTutorialDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = LessonSwipeTutorialDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainlayer = LessonSwipeTutorialDomainLayerDependencies(coreDataLayer: coreDataLayer, dataLayer: dataLayer)
    }
}
