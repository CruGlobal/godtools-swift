//
//  ToolTrainingTipsOnboardingViewsUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 10/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ToolTrainingTipsOnboardingViewsUserDefaultsCache {
    
    private let userDefaultsCache: SharedUserDefaultsCache
    
    required init(userDefaultsCache: SharedUserDefaultsCache) {
        
        self.userDefaultsCache = userDefaultsCache
    }
    
    private func getNumberOfViewsKey(tool: ToolDomainModel) -> String {
        
        return "ToolTrainingTipsOnboardingViewsService." + tool.name + "_" + tool.dataModelId
    }
    
    func getNumberOfToolTrainingTipViews(tool: ToolDomainModel) -> Int {
        
        if let number = userDefaultsCache.getValue(key: getNumberOfViewsKey(tool: tool)) as? NSNumber {
            return number.intValue
        }
        
        return 0
    }
    
    func storeToolTrainingTipViewed(tool: ToolDomainModel) {
        
        let numberOfViews: Int = getNumberOfToolTrainingTipViews(tool: tool)
        
        if numberOfViews < Int.max {
            
            let newNumberOfViews: Int = numberOfViews + 1
            
            userDefaultsCache.cache(
                value: NSNumber(value: newNumberOfViews),
                forKey: getNumberOfViewsKey(tool: tool)
            )
            
            userDefaultsCache.commitChanges()
        }
    }
}
