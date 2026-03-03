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
    
    private let cache: FavoritedResourcesCache
    
    init(persistence: any Persistence<FavoritedResourceDataModel, FavoritedResourceDataModel>, cache: FavoritedResourcesCache) {
        
        self.cache = cache
        
        super.init(
            externalDataFetch: NoExternalDataFetch<FavoritedResourceDataModel>(),
            persistence: persistence
        )
    }
    
    func getFavoritedResourcePublisher(id: String) -> AnyPublisher<FavoritedResourceDataModel?, Never> {
        
        // TODO: Implement. ~Levi
        
        return Just(nil)
            .eraseToAnyPublisher()
        
//        return cache.getFavoritedResourcePublisher(id: id)
//            .eraseToAnyPublisher()
    }
    
    func getResourceIsFavoritedPublisher(id: String) -> AnyPublisher<Bool, Never> {
        
        // TODO: Implement. ~Levi
        
        return Just(false)
            .eraseToAnyPublisher()
        
//        return cache.getFavoritedResourcePublisher(id: id)
//            .map { (object: FavoritedResourceDataModel?) in
//                return object != nil
//            }
//            .eraseToAnyPublisher()
    }
    
    func getResourceIsFavorited(id: String) -> Bool {
        
        // TODO: Implement. ~Levi
        return false
        //return cache.getResourceIsFavorited(id: id)
    }
    
    @MainActor func getFavoritedResourcesSortedByPositionPublisher() -> AnyPublisher<[FavoritedResourceDataModel], Never> {
        
        // TODO: Implement. ~Levi
        
        return Just([])
            .eraseToAnyPublisher()
        
//        return cache.getFavoritedResourcesSortedByPositionPublisher()
//            .eraseToAnyPublisher()
    }
    
    func storeFavoritedResourcesPublisher(ids: [String]) -> AnyPublisher<Void, Error> {
     
        // TODO: Implement. ~Levi
        
        return Just(Void())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
//        return cache.storeFavoritedResourcesPublisher(ids: ids)
//            .eraseToAnyPublisher()
    }
    
    func deleteFavoritedResourcePublisher(id: String) -> AnyPublisher<Void, Error> {
        
        // TODO: Implement. ~Levi
        return Just(Void())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
//        return cache.deleteFavoritedResourcePublisher(id: id)
//            .eraseToAnyPublisher()
    }
    
    func reorderFavoritedResourcePublisher(id: String, originalPosition: Int, newPosition: Int) -> AnyPublisher<[FavoritedResourceDataModel], Error> {
        
        // TODO: Implement. ~Levi
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        //return cache.reorderFavoritedResourcePublisher(id: id, originalPosition: originalPosition, newPosition: newPosition)
    }
}
