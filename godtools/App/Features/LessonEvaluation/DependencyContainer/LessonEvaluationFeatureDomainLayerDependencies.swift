//
//  LessonEvaluationFeatureDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class LessonEvaluationFeatureDomainLayerDependencies {
    
    private let dataLayer: LessonEvaluationFeatureDataLayerDependencies
    private let coreDataLayer: AppDataLayerDependencies
    
    init(dataLayer: LessonEvaluationFeatureDataLayerDependencies, coreDataLayer: AppDataLayerDependencies) {
        
        self.dataLayer = dataLayer
        self.coreDataLayer = coreDataLayer
    }
    
    func getLessonEvaluationInterfaceStringsUseCase() -> GetLessonEvaluationInterfaceStringsUseCase {
        return GetLessonEvaluationInterfaceStringsUseCase(
            getLessonEvaluationInterfaceStringsRepositoryInterface: dataLayer.getLessonEvaluationInterfaceStringsRepositoryInterface()
        )
    }
}
