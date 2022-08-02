//
//  FavoritedResourcesRepository.swift
//  godtools
//
//  Created by Levi Eggert on 8/2/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class FavoritedResourcesRepository {
    
    private let cache: FavoritedResourcesCache
    
    init(cache: FavoritedResourcesCache) {
        
        self.cache = cache
    }
    
    func store(resourceId: String) {
        
    }
    
    func delete(resourceId: String) {
        
    }
}
