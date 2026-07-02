//
//  ToolTrainingTipsOnboardingViewsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 5/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class ToolTrainingTipsOnboardingViewsRepository {
    
    private let cache: ToolTrainingTipsOnboardingViewsCache
    
    init(cache: ToolTrainingTipsOnboardingViewsCache) {
        
        self.cache = cache
    }
    
    func getNumberOfToolTrainingTipViews(toolId: String, toolName: String) -> Int {
        
        return cache.getNumberOfToolTrainingTipViews(toolId: toolId, toolName: toolName)
    }
    
    func storeToolTrainingTipViewed(toolId: String, toolName: String) {
        
        cache.storeToolTrainingTipViewed(toolId: toolId, toolName: toolName)
    }
}
