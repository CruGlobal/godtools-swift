//
//  UserFiltersUserDefaultsCache.swift
//  godtools
//
//  Created by Rachael Skeath on 11/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class UserFiltersUserDefaultsCache {
    
    private let sharedUserDefaultsCache: SharedUserDefaultsCache
    
    enum CacheKey {
        static let category = "categoryUserFilter"
        static let language = "languageUserFilter"
    }
    
    init(sharedUserDefaultsCache: SharedUserDefaultsCache) {
        
        self.sharedUserDefaultsCache = sharedUserDefaultsCache
    }
    
    func storeUserCategoryFilter(with id: String?) {
        
        sharedUserDefaultsCache.cache(value: id, forKey: CacheKey.category)
    }
    
    func storeUserLanguageFilter(with id: String?) {
        
        sharedUserDefaultsCache.cache(value: id, forKey: CacheKey.language)
    }
    
    func getUserCategoryFilter() -> String? {
        
        return sharedUserDefaultsCache.getValue(key: CacheKey.category) as? String
    }
    
    func getUserLanguageFilter() -> String? {
        
        return sharedUserDefaultsCache.getValue(key: CacheKey.language) as? String
    }
}
