//
//  ToolTrainingTipsOnboardingViewsService.swift
//  godtools
//
//  Created by Levi Eggert on 10/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ToolTrainingTipsOnboardingViewsService {
    
    private let cache: ToolTrainingTipsOnboardingViewsUserDefaultsCache
    
    required init(cache: ToolTrainingTipsOnboardingViewsUserDefaultsCache) {
        
        self.cache = cache
    }
    
    func getToolTrainingTipReachedMaximumViews(tool: ToolDomainModel) -> Bool {
        
        let numberOfViews: Int = getNumberOfToolTrainingTipViews(tool: tool)
        
        return numberOfViews >= 3
    }
    
    func getNumberOfToolTrainingTipViews(tool: ToolDomainModel) -> Int {
        
        return cache.getNumberOfToolTrainingTipViews(tool: tool)
    }
    
    func storeToolTrainingTipViewed(tool: ToolDomainModel) {
        
        cache.storeToolTrainingTipViewed(tool: tool)
    }
}
