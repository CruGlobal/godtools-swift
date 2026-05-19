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
    
    init(core: AppCoreDiContainer) {
        
        dataLayer = LessonSwipeTutorialDataLayerDependencies(coreDataLayer: core.dataLayer)
        domainlayer = LessonSwipeTutorialDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
