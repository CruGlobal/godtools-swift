//
//  FavoritedResourcesMemoryCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class FavoritedResourcesMemoryCache {
    
    private var favoritedResourceIds: [String] = Array()
    
    required init() {
        
    }
    
    func setFavoritedResourceIds(resourceIds: [String]) {
        favoritedResourceIds = resourceIds
    }
    
    func isFavorited(resourceId: String) -> Bool {
        return favoritedResourceIds.contains(resourceId)
    }
    
    func addToFavorites(resourceId: String) {
        if !favoritedResourceIds.contains(resourceId) {
            favoritedResourceIds.append(resourceId)
        }
    }
    
    func removeFromFavorites(resourceId: String) {
        if favoritedResourceIds.contains(resourceId), let index = favoritedResourceIds.firstIndex(of: resourceId) {
            favoritedResourceIds.remove(at: index)
        }
    }
}
