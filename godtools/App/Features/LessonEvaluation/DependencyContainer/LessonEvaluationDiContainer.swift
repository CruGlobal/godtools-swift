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
    
    init(core: AppCoreDiContainer) {
        
        dataLayer = LessonEvaluationDataLayerDependencies(coreDataLayer: core.dataLayer)
        domainLayer = LessonEvaluationDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
