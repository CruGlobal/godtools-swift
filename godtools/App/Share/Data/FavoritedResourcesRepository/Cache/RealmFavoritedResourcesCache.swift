//
//  RealmFavoritedResourcesCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmFavoritedResourcesCache {
        
    private let realmDatabase: RealmDatabase
        
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getNumberOfFavoritedResources() -> Int {
        return realmDatabase.openRealm().objects(RealmFavoritedResource.self).count
    }
    
    func getFavoritedResourcesChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return realmDatabase.openRealm().objects(RealmFavoritedResource.self).objectWillChange
            .eraseToAnyPublisher()
    }
    
    func getFavoritedResourcePublisher(id: String) -> AnyPublisher<FavoritedResourceDataModel?, Never> {
        
        let favoritedResource: FavoritedResourceDataModel? = getFavoritedResource(resourceId: id)
        
        return Just(favoritedResource)
            .eraseToAnyPublisher()
    }
    
    func getFavoritedResource(resourceId: String) -> FavoritedResourceDataModel? {
        
        guard let realmFavoritedResource = realmDatabase.openRealm().object(ofType: RealmFavoritedResource.self, forPrimaryKey: resourceId) else {
            return nil
        }
        
        return FavoritedResourceDataModel(realmFavoritedResource: realmFavoritedResource)
    }
    
    func getResourceIsFavorited(id: String) -> Bool {
            
        return realmDatabase.openRealm().object(ofType: RealmFavoritedResource.self, forPrimaryKey: id) != nil
    }
    
    func getFavoritedResourcesSortedByCreatedAt(ascendingOrder: Bool) -> [FavoritedResourceDataModel] {
        
        return realmDatabase.openRealm().objects(RealmFavoritedResource.self)
            .sorted(byKeyPath: #keyPath(RealmFavoritedResource.createdAt), ascending: ascendingOrder)
            .map({FavoritedResourceDataModel(realmFavoritedResource: $0)})
    }
    
    func getFavoritedResourcesSortedByCreatedAtPublisher(ascendingOrder: Bool) -> AnyPublisher<[FavoritedResourceDataModel], Never> {
        
        let favoritedResources: [FavoritedResourceDataModel] = realmDatabase.openRealm().objects(RealmFavoritedResource.self)
            .sorted(byKeyPath: #keyPath(RealmFavoritedResource.createdAt), ascending: ascendingOrder)
            .map({
                return FavoritedResourceDataModel(realmFavoritedResource: $0)
            })
        
        return Just(favoritedResources)
            .eraseToAnyPublisher()
    }
    
    func storeFavoritedResourcesPublisher(ids: [String]) -> AnyPublisher<[FavoritedResourceDataModel], Error> {
        
        let newFavoritedResources: [FavoritedResourceDataModel] = ids.map {
            return FavoritedResourceDataModel(id: $0)
        }
        
        return realmDatabase.writeObjectsPublisher { (realm: Realm) in
            
            let realmFavoritedResources: [RealmFavoritedResource] = newFavoritedResources.map {
                
                let realmFavoritedResource = RealmFavoritedResource()
                realmFavoritedResource.mapFrom(dataModel: $0)
                
                return realmFavoritedResource
            }
            
            return realmFavoritedResources
        }
        .map { _ in
            
            return newFavoritedResources
        }
        .eraseToAnyPublisher()
    }
    
    func deleteFavoritedResourcePublisher(id: String) -> AnyPublisher<Void, Error> {
        
        return realmDatabase.readObjectPublisher(primaryKey: id)
            .flatMap({ (object: RealmFavoritedResource?) -> AnyPublisher<Void, Error> in
                
                guard let object = object else {
                    return Just(Void()).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                return self.realmDatabase.deleteObjectsPublisher(objects: [object])
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
