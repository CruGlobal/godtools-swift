//
//  LessonEvaluationDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class LessonEvaluationDiContainer {
    
    let dataLayer: LessonEvaluationDataLayerDependencies
    let domainLayer: LessonEvaluationDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies) {
        
        dataLayer = LessonEvaluationDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = LessonEvaluationDomainLayerDependencies(coreDataLayer: coreDataLayer, coreDomainLayer: coreDomainLayer, dataLayer: dataLayer)
    }
}
