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
    
    func getToolTrainingTipReachedMaximumViews(toolId: String, primaryLanguage: AppLanguageDomainModel) -> Bool {
        
        let numberOfViews: Int = getNumberOfToolTrainingTipViews(toolId: toolId, primaryLanguage: primaryLanguage)
        
        return numberOfViews >= 3
    }
    
    func getNumberOfToolTrainingTipViews(toolId: String, primaryLanguage: AppLanguageDomainModel) -> Int {
        
        return cache.getNumberOfToolTrainingTipViews(toolId: toolId, primaryLanguage: primaryLanguage)
    }
    
    func storeToolTrainingTipViewed(toolId: String, primaryLanguage: AppLanguageDomainModel) {
        
        cache.storeToolTrainingTipViewed(toolId: toolId, primaryLanguage: primaryLanguage)
    }
}
