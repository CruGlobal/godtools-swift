//
//  ToolTrainingTipsOnboardingViewsUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 10/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ToolTrainingTipsOnboardingViewsUserDefaultsCache: ToolTrainingTipsOnboardingViewsCacheType {
    
    private let userDefaultsCache: SharedUserDefaultsCache
    
    required init(userDefaultsCache: SharedUserDefaultsCache) {
        
        self.userDefaultsCache = userDefaultsCache
    }
    
    private func getNumberOfViewsKey(resource: ResourceModel) -> String {
        
        return "ToolTrainingTipsOnboardingViewsService." + resource.name + "_" + resource.id
    }
    
    func getNumberOfToolTrainingTipViews(resource: ResourceModel) -> Int {
        
        if let number = userDefaultsCache.getValue(key: getNumberOfViewsKey(resource: resource)) as? NSNumber {
            return number.intValue
        }
        
        return 0
    }
    
    func storeToolTrainingTipViewed(resource: ResourceModel) {
        
        let numberOfViews: Int = getNumberOfToolTrainingTipViews(resource: resource)
        
        if numberOfViews < Int.max {
            
            let newNumberOfViews: Int = numberOfViews + 1
            
            userDefaultsCache.cache(
                value: NSNumber(value: newNumberOfViews),
                forKey: getNumberOfViewsKey(resource: resource)
            )
            
            userDefaultsCache.commitChanges()
        }
    }
}
