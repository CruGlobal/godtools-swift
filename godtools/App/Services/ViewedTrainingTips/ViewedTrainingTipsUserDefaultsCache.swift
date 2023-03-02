//
//  ViewedTrainingTipsUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 12/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

@available(*, deprecated)
class ViewedTrainingTipsUserDefaultsCache: ViewedTrainingTipsCacheType {
    
    private let sharedUserDefaults: SharedUserDefaultsCache
    
    required init(sharedUserDefaults: SharedUserDefaultsCache) {
        
        self.sharedUserDefaults = sharedUserDefaults
    }
    
    func containsViewedTrainingTip(id: String) -> Bool {
        
        return sharedUserDefaults.getValue(key: id) != nil
    }
    
    func storeViewedTrainingTip(viewedTrainingTip: ViewedTrainingTipType) {
        
        sharedUserDefaults.cache(value: viewedTrainingTip.id, forKey: viewedTrainingTip.id)
        sharedUserDefaults.commitChanges()
    }
}
