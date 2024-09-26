//
//  LessonCompletionFeatureDomainLayerDependencies.swift
//  godtools
//
//  Created by Rachael Skeath on 9/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class LessonCompletionFeatureDomainLayerDependencies {
    
    private let dataLayer: LessonCompletionFeatureDataLayerDependencies
    private let coreDataLayer: AppDataLayerDependencies
    
    init(dataLayer: LessonCompletionFeatureDataLayerDependencies, coreDataLayer: AppDataLayerDependencies) {
        self.dataLayer = dataLayer
        self.coreDataLayer = coreDataLayer
    }
    
    func getStoreLessonProgressUseCase() -> StoreLessonProgressUseCase {
        return StoreLessonProgressUseCase(
            storeLessonProgressRepository: dataLayer.getStoreLessonProgressRepositoryInterface()
        )
    }
}
