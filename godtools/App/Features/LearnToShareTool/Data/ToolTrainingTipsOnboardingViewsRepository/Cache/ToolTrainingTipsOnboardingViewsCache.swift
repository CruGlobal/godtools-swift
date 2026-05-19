//
//  ToolTrainingTipsOnboardingViewsCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class ToolTrainingTipsOnboardingViewsCache {
    
    private let userDefaultsCache: UserDefaultsCacheInterface
    
    init(userDefaultsCache: UserDefaultsCacheInterface) {
        
        self.userDefaultsCache = userDefaultsCache
    }
    
    private func getNumberOfViewsKey(toolId: String, toolName: String) -> String {
                
        return "ToolTrainingTipsOnboardingViewsService." + toolName + "_" + toolId
    }
    
    func getNumberOfToolTrainingTipViews(toolId: String, toolName: String) -> Int {
        
        if let number = userDefaultsCache.getValue(key: getNumberOfViewsKey(toolId: toolId, toolName: toolName)) as? NSNumber {
            return number.intValue
        }
        
        return 0
    }
    
    func storeToolTrainingTipViewed(toolId: String, toolName: String) {
        
        let numberOfViews: Int = getNumberOfToolTrainingTipViews(toolId: toolId, toolName: toolName)
        
        if numberOfViews < Int.max {
            
            let newNumberOfViews: Int = numberOfViews + 1
            
            userDefaultsCache.cache(
                value: NSNumber(value: newNumberOfViews),
                forKey: getNumberOfViewsKey(toolId: toolId, toolName: toolName)
            )
            
            userDefaultsCache.commitChanges()
        }
    }
}
