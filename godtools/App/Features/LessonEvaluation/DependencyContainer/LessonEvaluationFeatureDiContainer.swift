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
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies) {
        
        dataLayer = LessonEvaluationFeatureDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = LessonEvaluationFeatureDomainLayerDependencies(coreDataLayer: coreDataLayer, coreDomainLayer: coreDomainLayer, dataLayer: dataLayer)
    }
}
