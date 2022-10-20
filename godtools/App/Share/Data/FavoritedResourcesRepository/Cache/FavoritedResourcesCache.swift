//
//  FavoritedResourcesCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class FavoritedResourcesCache {
        
    private let realmDatabase: RealmDatabase
        
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    var numberOfFavoritedResources: Int {
        return realmDatabase.openRealm().objects(RealmFavoritedResource.self).count
    }
    
    func getFavoritedResourcesChanged() -> AnyPublisher<Void, Never> {
        return realmDatabase.openRealm().objects(RealmFavoritedResource.self).objectWillChange
            .eraseToAnyPublisher()
    }
    
    func getFavoritedResource(resourceId: String) -> FavoritedResourceModel? {
        
        guard let realmFavoritedResource = realmDatabase.openRealm().object(ofType: RealmFavoritedResource.self, forPrimaryKey: resourceId) else {
            return nil
        }
        
        return FavoritedResourceModel(model: realmFavoritedResource)
    }
    
    func getFavoritedResources() -> [FavoritedResourceModel] {
        
        return realmDatabase.openRealm().objects(RealmFavoritedResource.self)
            .map({FavoritedResourceModel(model: $0)})
    }
    
    func getFavoritedResourcesSortedByCreatedAt(ascendingOrder: Bool) -> [FavoritedResourceModel] {
        
        return realmDatabase.openRealm().objects(RealmFavoritedResource.self)
            .sorted(byKeyPath: #keyPath(RealmFavoritedResource.createdAt), ascending: ascendingOrder)
            .map({FavoritedResourceModel(model: $0)})
    }
    
    func storeFavoritedResource(resourceId: String) -> Result<FavoritedResourceModel, Error> {
        
        let favoritedResource = FavoritedResourceModel(resourceId: resourceId)
        
        let realm: Realm = realmDatabase.openRealm()
        
        do {
            
            try realm.safeWrite {
                
                let realmFavoritedResource: RealmFavoritedResource = RealmFavoritedResource()
                realmFavoritedResource.mapFrom(model: favoritedResource)
                
                realm.add(realmFavoritedResource, update: .all)
            }
            
            return .success(favoritedResource)
        }
        catch let error {
            
            return .failure(error)
        }
    }
    
    func deleteFavoritedResource(resourceId: String) -> Result<FavoritedResourceModel, Error> {

        let realm: Realm = realmDatabase.openRealm()
        
        guard let realmFavoritedResource = realm.object(ofType: RealmFavoritedResource.self, forPrimaryKey: resourceId) else {
            return .failure(NSError.errorWithDescription(description: "Favorited resource with resourceId \(resourceId) does not exist in the realm database."))
        }
        
        let favoritedResource: FavoritedResourceModel = FavoritedResourceModel(model: realmFavoritedResource)
        
        do {
            
            try realm.write {
                realm.delete(realmFavoritedResource)
            }
            
            return .success(favoritedResource)
        }
        catch let error {
            
            return .failure(error)
        }
    }
}
