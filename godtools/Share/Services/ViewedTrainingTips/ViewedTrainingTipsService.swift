//
//  ViewedTrainingTipsService.swift
//  godtools
//
//  Created by Levi Eggert on 12/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ViewedTrainingTipsService {
    
    private let cache: ViewedTrainingTipsCacheType
    
    required init(cache: ViewedTrainingTipsCacheType) {
        
        self.cache = cache
    }
    
    func containsViewedTrainingTip(viewedTrainingTip: ViewedTrainingTipType) -> Bool {
        
        return cache.containsViewedTrainingTip(viewedTrainingTip: viewedTrainingTip)
    }
    
    func storeViewedTrainingTip(viewedTrainingTip: ViewedTrainingTipType) {
        
        cache.storeViewedTrainingTip(viewedTrainingTip: viewedTrainingTip)
    }
}
