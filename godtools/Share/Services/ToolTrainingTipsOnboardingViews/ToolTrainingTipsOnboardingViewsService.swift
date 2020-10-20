//
//  ToolTrainingTipsOnboardingViewsService.swift
//  godtools
//
//  Created by Levi Eggert on 10/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ToolTrainingTipsOnboardingViewsService {
    
    private let cache: ToolTrainingTipsOnboardingViewsCacheType
    
    required init(cache: ToolTrainingTipsOnboardingViewsCacheType) {
        
        self.cache = cache
    }
    
    func getNumberOfToolTrainingTipViews(resource: ResourceModel) -> Int {
        
        return cache.getNumberOfToolTrainingTipViews(resource: resource)
    }
    
    func storeToolTrainingTipViewed(resource: ResourceModel) {
        
        cache.storeToolTrainingTipViewed(resource: resource)
    }
}
