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
    
    private let cache: RealmFavoritedResourcesCache
    
    init(cache: RealmFavoritedResourcesCache) {
        
        self.cache = cache
    }
    
    func getNumberOfFavoritedResources() -> Int {
        return cache.getNumberOfFavoritedResources()
    }
    
    @MainActor func getFavoritedResourcesChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return cache.getFavoritedResourcesChangedPublisher()
            .eraseToAnyPublisher()
    }
    
    func getFavoritedResourcePublisher(id: String) -> AnyPublisher<FavoritedResourceDataModel?, Never> {
        
        return cache.getFavoritedResourcePublisher(id: id)
            .eraseToAnyPublisher()
    }
    
    func getResourceIsFavoritedPublisher(id: String) -> AnyPublisher<Bool, Never> {
        
        return cache.getFavoritedResourcePublisher(id: id)
            .map { (object: FavoritedResourceDataModel?) in
                return object != nil
            }
            .eraseToAnyPublisher()
    }
    
    func getResourceIsFavorited(id: String) -> Bool {
        return cache.getResourceIsFavorited(id: id)
    }
    
    @MainActor func getFavoritedResourcesSortedByPositionPublisher() -> AnyPublisher<[FavoritedResourceDataModel], Never> {
        
        return cache.getFavoritedResourcesSortedByPositionPublisher()
            .eraseToAnyPublisher()
    }
    
    func storeFavoritedResourcesPublisher(ids: [String]) -> AnyPublisher<Void, Never> {
     
        return cache.storeFavoritedResourcesPublisher(ids: ids)
            .eraseToAnyPublisher()
    }
    
    func deleteFavoritedResourcePublisher(id: String) -> AnyPublisher<Void, Error> {
        
        return cache.deleteFavoritedResourcePublisher(id: id)
            .eraseToAnyPublisher()
    }
    
    func reorderFavoritedResourcePublisher(id: String, originalPosition: Int, newPosition: Int) -> AnyPublisher<[FavoritedResourceDataModel], Error> {
        
        return cache.reorderFavoritedResourcePublisher(id: id, originalPosition: originalPosition, newPosition: newPosition)
    }
}
