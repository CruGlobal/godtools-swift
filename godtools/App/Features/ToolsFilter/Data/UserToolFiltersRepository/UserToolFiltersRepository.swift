//
//  UserToolFiltersRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 11/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class UserToolFiltersRepository {
    
    private let cache: RealmUserToolFiltersCache
    
    init(cache: RealmUserToolFiltersCache) {
        
        self.cache = cache
    }
    
    func storeUserToolCategoryFilter(with id: String?) {
        if let categoryId = id {
            cache.storeUserToolCategoryFilter(categoryId: categoryId)
        } else {
            cache.removeUserToolCategoryFilter()
        }
    }
    
    func storeUserToolLanguageFilter(with id: String?) {
        if let languageId = id {
            cache.storeUserToolLanguageFilter(languageId: languageId)
        } else {
            cache.removeUserToolLanguageFilter()
        }
    }
    
    func getUserToolCategoryFilter() -> UserToolCategoryFilterDataModel? {
        return cache.getUserToolCategoryFilter()
    }
    
    func getUserToolLanguageFilter() -> UserToolLanguageFilterDataModel? {
        return cache.getUserToolLanguageFilter()
    }
}
