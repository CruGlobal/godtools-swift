//
//  ViewedTrainingTipsService.swift
//  godtools
//
//  Created by Levi Eggert on 12/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

// TODO: We're transitioning away from storing completed tips in UserDefaults and using Realm instead in CompletedTrainingTipRepository.
@available(*, deprecated)
class ViewedTrainingTipsService {
    
    private let cache: ViewedTrainingTipsCacheType
    
    required init(cache: ViewedTrainingTipsCacheType) {
        
        self.cache = cache
    }
    
    func containsViewedTrainingTip(id: String) -> Bool {
        
        return cache.containsViewedTrainingTip(id: id)
    }
}
