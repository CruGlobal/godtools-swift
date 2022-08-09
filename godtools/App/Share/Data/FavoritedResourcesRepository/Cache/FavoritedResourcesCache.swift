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

@available(*, deprecated)
class FavoritedResourcesCache {
        
    private let realmDatabase: RealmDatabase
    
    @available(*, deprecated)
    let resourceFavorited: SignalValue<String> = SignalValue()
    @available(*, deprecated)
    let resourceUnfavorited: SignalValue<String> = SignalValue()
    @available(*, deprecated)
    let resourceSorted: SignalValue<String> = SignalValue()
    
    required init(realmDatabase: RealmDatabase) {
        
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
            
            try realm.write {
                
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
    
    // MARK: -
    
    @available(*, deprecated)
    func getSortedFavoritedResources() -> [FavoritedResourceModel] {
        let realm: Realm = realmDatabase.mainThreadRealm
        return getSortedFavoritedResources(realm: realm)
    }
    
    @available(*, deprecated)
    func getSortedFavoritedResources(realm: Realm) -> [FavoritedResourceModel] {
        let realmFavoritedResource = realm.objects(RealmFavoritedResource.self).sorted(byKeyPath: #keyPath(RealmFavoritedResource.createdAt), ascending: false)
        return Array(realmFavoritedResource.map({FavoritedResourceModel(model: $0)}))
        
    }
    
    @available(*, deprecated)
    func isFavorited(resourceId: String) -> Bool {
        let realm: Realm = realmDatabase.mainThreadRealm
        return realm.object(ofType: RealmFavoritedResource.self, forPrimaryKey: resourceId) != nil
    }
    
    @available(*, deprecated)
    func toggleFavorited(resourceId: String) {
        
        if isFavorited(resourceId: resourceId) {
            removeFromFavorites(resourceId: resourceId)
        }
        else {
            addToFavorites(resourceId: resourceId)
        }
    }
    
    @available(*, deprecated)
    func addToFavorites(resourceId: String) {
        
        storeFavoritedResource(resourceId: resourceId)
        
        resourceFavorited.accept(value: resourceId)
    }
    
    @available(*, deprecated)
    func removeFromFavorites(resourceId: String) {
        
        deleteFavoritedResource(resourceId: resourceId)
        
        resourceUnfavorited.accept(value: resourceId)
    }
    
    @available(*, deprecated)
    func setSortOrder(resourceId: String, newSortOrder: Int) {
        
        resourceSorted.accept(value: resourceId)
    }
    
    @available(*, deprecated)
    private func flattenSortOrder(realm: Realm, startSortOrder: Int) -> Error? {
        
        return nil
    }
}
