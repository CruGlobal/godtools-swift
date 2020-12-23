//
//  ViewedTrainingTipsUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 12/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ViewedTrainingTipsUserDefaultsCache: ViewedTrainingTipsCacheType {
    
    private let sharedUserDefaults: SharedUserDefaultsCache
    
    required init(sharedUserDefaults: SharedUserDefaultsCache) {
        
        self.sharedUserDefaults = sharedUserDefaults
    }
    
    func containsViewedTrainingTip(viewedTrainingTip: ViewedTrainingTipType) -> Bool {
        
        return sharedUserDefaults.getValue(key: viewedTrainingTip.id) != nil
    }
    
    func storeViewedTrainingTip(viewedTrainingTip: ViewedTrainingTipType) {
        
        sharedUserDefaults.cache(value: viewedTrainingTip.id, forKey: viewedTrainingTip.id)
        sharedUserDefaults.commitChanges()
    }
}
