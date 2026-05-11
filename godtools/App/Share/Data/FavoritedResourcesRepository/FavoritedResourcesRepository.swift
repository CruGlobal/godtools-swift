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

    @available(*, deprecated) // Remove and use throws. ~Levi
    func getResourceIsFavoritedNonThrowing(id: String) -> Bool {
                
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
    
    @available(*, deprecated) // Remove and use async throws. ~Levi
    func getFavoritedResourcesSortedByPositionPublisher() -> AnyPublisher<[FavoritedResourceDataModel], Error> {
     
        return AnyPublisher() {
            
            return try await self.cache.getFavoritedResourcesSortedByPosition()
        }
        .eraseToAnyPublisher()
    }
    
    @available(*, deprecated) // Remove and use async throws. ~Levi
    func storeFavoritedResourcesPublisher(ids: [String]) -> AnyPublisher<[FavoritedResourceDataModel], Error> {
     
        return AnyPublisher() {
            
            return try await self.cache.storeFavoritedResources(ids: ids)
        }
        .eraseToAnyPublisher()
    }
    
    @available(*, deprecated) // Remove and use async throws. ~Levi
    func deleteFavoritedResourcePublisher(id: String) -> AnyPublisher<[FavoritedResourceDataModel], Error> {
        
        return AnyPublisher() {
            
            return try await self.cache.deleteFavoritedResource(id: id)
        }
        .eraseToAnyPublisher()
    }
    
    @available(*, deprecated) // Remove and use async throws. ~Levi
    func reorderFavoritedResourcePublisher(id: String, originalPosition: Int, newPosition: Int) -> AnyPublisher<[FavoritedResourceDataModel], Error> {
        
        return AnyPublisher() {
            
            return try await self.cache.reorderFavoritedResource(id: id, originalPosition: originalPosition, newPosition: newPosition)
        }
        .eraseToAnyPublisher()
    }
}
