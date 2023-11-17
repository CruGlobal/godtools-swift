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
    
    func storeUserCategoryFilter(with id: String?) {
        cache.storeUserCategoryFilter(with: id)
    }
    
    func storeUserLanguageFilter(with id: String?) {
        cache.storeUserLanguageFilter(with: id)
    }
    
    func getUserCategoryFilter() -> String? {
        return cache.getUserCategoryFilter()
    }
    
    func getUserLanguageFilter() -> String? {
        return cache.getUserLanguageFilter()
    }
}
