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

final class FavoritedResourcesRepository: RepositorySync<FavoritedResourceDataModel, NoExternalDataFetch<FavoritedResourceDataModel>> {
    
    let cache: FavoritedResourcesCache
    
    init(persistence: any Persistence<FavoritedResourceDataModel, FavoritedResourceDataModel>, cache: FavoritedResourcesCache) {
        
        self.cache = cache
        
        super.init(
            externalDataFetch: NoExternalDataFetch<FavoritedResourceDataModel>(),
            persistence: persistence
        )
    }

    func getResourceIsFavorited(id: String) -> Bool {
        
        // TODO: Handle Error. ~Levi
        
        do {
            return try persistence.getDataModel(id: id) != nil
        }
        catch _ {
            return false
        }
    }
    
    func getFavoritedResourcesSortedByPositionPublisher() -> AnyPublisher<[FavoritedResourceDataModel], Error> {
     
        return AnyPublisher() {
            
            return try await self.cache.getFavoritedResourcesSortedByPosition()
        }
        .eraseToAnyPublisher()
    }
    
    func storeFavoritedResourcesPublisher(ids: [String]) -> AnyPublisher<[FavoritedResourceDataModel], Error> {
     
        return AnyPublisher() {
            
            return try await self.cache.storeFavoritedResources(ids: ids)
        }
        .eraseToAnyPublisher()
    }
    
    func deleteFavoritedResourcePublisher(id: String) -> AnyPublisher<[FavoritedResourceDataModel], Error> {
        
        return AnyPublisher() {
            
            return try await self.cache.deleteFavoritedResource(id: id)
        }
        .eraseToAnyPublisher()
    }
    
    func reorderFavoritedResourcePublisher(id: String, originalPosition: Int, newPosition: Int) -> AnyPublisher<[FavoritedResourceDataModel], Error> {
        
        return AnyPublisher() {
            
            return try await self.cache.reorderFavoritedResource(id: id, originalPosition: originalPosition, newPosition: newPosition)
        }
        .eraseToAnyPublisher()
    }
}
