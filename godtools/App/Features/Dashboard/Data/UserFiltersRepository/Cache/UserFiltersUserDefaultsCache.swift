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
    
    func storeUserFilter(filter: UserFilterType) {
        
        let value: String
        let key: String
        
        switch filter {
        case .category(let id):
            value = id
            key = CacheKey.category
       
        case .language(let id):
            value = id
            key = CacheKey.language
        }
        
        sharedUserDefaultsCache.cache(value: value, forKey: key)
    }
    
    func getUserCategoryFilter() -> String? {
        
        return sharedUserDefaultsCache.getValue(key: CacheKey.category) as? String
    }
    
    func getUserLanguageFilter() -> String? {
        
        return sharedUserDefaultsCache.getValue(key: CacheKey.language) as? String
    }
}
