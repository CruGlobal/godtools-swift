//
//  LessonCompletionFeatureDiContainer.swift
//  godtools
//
//  Created by Rachael Skeath on 9/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class LessonCompletionFeatureDiContainer {
    
    let dataLayer: LessonCompletionFeatureDataLayerDependencies
    let domainLayer: LessonCompletionFeatureDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = LessonCompletionFeatureDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = LessonCompletionFeatureDomainLayerDependencies(dataLayer: dataLayer, coreDataLayer: coreDataLayer)
    }
}
