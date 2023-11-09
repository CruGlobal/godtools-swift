//
//  UserFiltersRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 11/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class UserFiltersRepository {
    
    private let cache: UserFiltersUserDefaultsCache
    
    init(cache: UserFiltersUserDefaultsCache) {
        
        self.cache = cache
    }
    
    func storeUserFilters(filter: UserFilterType) {
        
        cache.storeUserFilter(filter: filter)
    }
}
