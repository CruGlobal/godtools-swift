//
//  FavoritedResourcesRepository.swift
//  godtools
//
//  Created by Levi Eggert on 8/2/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import Combine

final class FavoritedResourcesRepository {
    
    private let cache: FavoritedResourcesCache
    
    init(cache: FavoritedResourcesCache) {
        
        self.cache = cache
    }
    
    @MainActor func observeCollectionChangesPublisher() -> AnyPublisher<Void, Error> {
        return cache
            .persistence
            .observeCollectionChangesPublisher()
    }
    
    func getObjectCount() throws -> Int {
        return try cache.persistence.getObjectCount()
    }
    
    func getResourceIsFavorited(id: String) -> Bool {
        
        do {
            return try cache.persistence.getDataModel(id: id) != nil
        }
        catch _ {
            return false
        }
    }
    
    func getFavoritedResourcesSortedByPosition() async throws -> [FavoritedResourceDataModel] {
        return try await cache.getFavoritedResourcesSortedByPosition()
    }
    
    func storeFavoritedResources(ids: [String]) async throws -> [FavoritedResourceDataModel] {
     
        return try await self.cache.storeFavoritedResources(ids: ids)
    }
    
    func deleteFavoritedResource(id: String) async throws -> [FavoritedResourceDataModel] {
        
        return try await self.cache.deleteFavoritedResource(id: id)
    }
    
    func reorderFavoritedResource(id: String, originalPosition: Int, newPosition: Int) async throws -> [FavoritedResourceDataModel] {
        
        return try await cache.reorderFavoritedResource(id: id, originalPosition: originalPosition, newPosition: newPosition)
    }
}
