//
//  LessonEvaluationFeatureDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class LessonEvaluationFeatureDiContainer {
    
    let dataLayer: LessonEvaluationFeatureDataLayerDependencies
    let domainLayer: LessonEvaluationFeatureDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = LessonEvaluationFeatureDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = LessonEvaluationFeatureDomainLayerDependencies(dataLayer: dataLayer, coreDataLayer: coreDataLayer)
    }
}
