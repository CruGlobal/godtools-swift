//
//  ToolTrainingTipsOnboardingViewsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 5/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class ToolTrainingTipsOnboardingViewsRepository: Sendable {
    
    private let cache: ToolTrainingTipsOnboardingViewsCache
    
    init(cache: ToolTrainingTipsOnboardingViewsCache) {
        
        self.cache = cache
    }
    
    func getNumberOfToolTrainingTipViews(toolId: String, toolName: String) async -> Int {
        
        return await cache.getNumberOfToolTrainingTipViews(toolId: toolId, toolName: toolName)
    }
    
    func storeToolTrainingTipViewed(toolId: String, toolName: String) async {
        
        await cache.storeToolTrainingTipViewed(toolId: toolId, toolName: toolName)
    }
}
