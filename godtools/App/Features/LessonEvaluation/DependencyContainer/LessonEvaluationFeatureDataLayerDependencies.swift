//
//  LessonEvaluationFeatureDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class LessonEvaluationFeatureDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    // MARK: - Domain Interface
    
    func getLessonEvaluationInterfaceStringsRepositoryInterface() -> GetLessonEvaluationInterfaceStringsRepositoryInterface {
        return GetLessonEvaluationInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
}
