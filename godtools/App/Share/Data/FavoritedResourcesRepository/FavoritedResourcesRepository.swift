//
//  FavoritedResourcesRepository.swift
//  godtools
//
//  Created by Levi Eggert on 8/2/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class FavoritedResourcesRepository {
    
    private let cache: FavoritedResourcesCache
    
    init(cache: FavoritedResourcesCache) {
        
        self.cache = cache
    }
    
    var numberOfFavoritedResources: Int {
        return cache.numberOfFavoritedResources
    }
    
    func getFavoritedResourcesChanged() -> AnyPublisher<Void, Never> {
        return cache.getFavoritedResourcesChanged()
    }
    
    func getResourceIsFavorited(resourceId: String) -> Bool {
        
        return cache.getFavoritedResource(resourceId: resourceId) != nil
    }
    
    func getFavoritedResource(resourceId: String) -> FavoritedResourceModel? {
        
        return cache.getFavoritedResource(resourceId: resourceId)
    }
    
    func getFavoritedResources() -> [FavoritedResourceModel] {
        
        return cache.getFavoritedResources()
    }
    
    func getFavoritedResourcesSortedByCreatedAt(ascendingOrder: Bool) -> [FavoritedResourceModel] {
        
        return cache.getFavoritedResourcesSortedByCreatedAt(ascendingOrder: ascendingOrder)
    }
    
    func storeFavoritedResource(resourceId: String) -> Result<FavoritedResourceModel, Error> {
        
        return cache.storeFavoritedResource(resourceId: resourceId)
    }
    
    func deleteFavoritedResource(resourceId: String) -> Result<FavoritedResourceModel, Error> {

        return cache.deleteFavoritedResource(resourceId: resourceId)
    }
}
