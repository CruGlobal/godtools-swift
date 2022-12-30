//
//  SetupParallelLanguageViewedRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class SetupParallelLanguageViewedRepository {
    
    private let cache: SetupParallelLanguageViewedUserDefaultsCache
    
    init(cache: SetupParallelLanguageViewedUserDefaultsCache) {
        
        self.cache = cache
    }
    
    func getSetupParallelLanguageViewed() -> Bool {
        
        return cache.getSetupParallelLanguageViewed()
    }
    
    func storeSetupParallelLanguageViewed(viewed: Bool) {
        
        cache.storeSetupParallelLanguageViewed(viewed: viewed)
    }
}
