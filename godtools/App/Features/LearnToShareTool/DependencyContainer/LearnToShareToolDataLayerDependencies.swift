//
//  LearnToShareToolDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 12/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class LearnToShareToolDataLayerDependencies: Sendable {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    func getToolTrainingTipsOnboardingViewsRepository() -> ToolTrainingTipsOnboardingViewsRepository {
        return ToolTrainingTipsOnboardingViewsRepository(
            cache: ToolTrainingTipsOnboardingViewsCache(
                userDefaultsCache: coreDataLayer.getUserDefaultsCache()
            )
        )
    }
}
