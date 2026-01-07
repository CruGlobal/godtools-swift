//
//  ToolTrainingTipsOnboardingViewsService.swift
//  godtools
//
//  Created by Levi Eggert on 10/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

final class ToolTrainingTipsOnboardingViewsService {
    
    private let cache: ToolTrainingTipsOnboardingViewsUserDefaultsCache
    
    init(cache: ToolTrainingTipsOnboardingViewsUserDefaultsCache) {
        
        self.cache = cache
    }
    
    @MainActor func getToolTrainingTipReachedMaximumViews(toolId: String, primaryLanguage: AppLanguageDomainModel) -> Bool {
        
        let numberOfViews: Int = getNumberOfToolTrainingTipViews(toolId: toolId, primaryLanguage: primaryLanguage)
        
        return numberOfViews >= 3
    }
    
    @MainActor func getNumberOfToolTrainingTipViews(toolId: String, primaryLanguage: AppLanguageDomainModel) -> Int {
        
        return cache.getNumberOfToolTrainingTipViews(toolId: toolId, primaryLanguage: primaryLanguage)
    }
    
    @MainActor func storeToolTrainingTipViewed(toolId: String, primaryLanguage: AppLanguageDomainModel) {
        
        cache.storeToolTrainingTipViewed(toolId: toolId, primaryLanguage: primaryLanguage)
    }
}
