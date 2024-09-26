//
//  LessonCompletionFeatureDataLayerDependencies.swift
//  godtools
//
//  Created by Rachael Skeath on 9/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class LessonCompletionFeatureDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    // MARK: - Domain Interface
    
    func getStoreLessonProgressRepositoryInterface() -> StoreLessonProgressRepositoryInterface {
        return StoreLessonProgressRepository(
            lessonCompletionRepository: coreDataLayer.getLessonCompletionRepository()
        )
    }
}
