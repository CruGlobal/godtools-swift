//
//  FavoritedResourcesCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class FavoritedResourcesCache {
    
    typealias ResourceId = String
    
    private let realmDatabase: RealmDatabase
    
    let resourceFavorited: SignalValue<ResourceId> = SignalValue()
    let resourceUnfavorited: SignalValue<ResourceId> = SignalValue()
    let resourceSorted: SignalValue<ResourceId> = SignalValue()
    
    required init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func store(resourceId: String) {
        addToFavorites(resourceId: resourceId)
    }
    
    func delete(resourceId: String) {
        removeFromFavorites(resourceId: resourceId)
    }
    
    
    // MARK: -
    
    func getFavoritedResources() -> [FavoritedResourceModel] {
        return getFavoritedResources(realm: realmDatabase.mainThreadRealm)
    }
    
    func getFavoritedResources(realm: Realm) -> [FavoritedResourceModel] {
        return Array(realm.objects(RealmFavoritedResource.self)).map({FavoritedResourceModel(model: $0)})
    }
    
    func getFavoritedResource(resourceId: String) -> FavoritedResourceModel? {
        let realm: Realm = realmDatabase.mainThreadRealm
        if let realmFavoritedResource = realm.object(ofType: RealmFavoritedResource.self, forPrimaryKey: resourceId) {
            return FavoritedResourceModel(model: realmFavoritedResource)
        }
        return nil
    }
    
    func getSortedFavoritedResources() -> [FavoritedResourceModel] {
        let realm: Realm = realmDatabase.mainThreadRealm
        return getSortedFavoritedResources(realm: realm)
    }
    
    func getSortedFavoritedResources(realm: Realm) -> [FavoritedResourceModel] {
        let realmFavoritedResource = realm.objects(RealmFavoritedResource.self).sorted(byKeyPath: "sortOrder", ascending: true)
        return Array(realmFavoritedResource.map({FavoritedResourceModel(model: $0)}))
    }
    
    func isFavorited(resourceId: String) -> Bool {
        let realm: Realm = realmDatabase.mainThreadRealm
        return realm.object(ofType: RealmFavoritedResource.self, forPrimaryKey: resourceId) != nil
    }
    
    func toggleFavorited(resourceId: String) {
        
        if isFavorited(resourceId: resourceId) {
            removeFromFavorites(resourceId: resourceId)
        }
        else {
            addToFavorites(resourceId: resourceId)
        }
    }
    
    func addToFavorites(resourceId: String) {
        
        addToFavorites(realm: realmDatabase.mainThreadRealm, resourceId: resourceId)
    }
    
    func addToFavorites(realm: Realm, resourceId: String) {
                
        if realm.object(ofType: RealmFavoritedResource.self, forPrimaryKey: resourceId) != nil {
            return
        }
        
        flattenSortOrder(realm: realm, startSortOrder: 1)
        
        let realmFavoritedResource = RealmFavoritedResource()
        realmFavoritedResource.resourceId = resourceId
        realmFavoritedResource.sortOrder = 0
        
        do {
            try realm.write {
                realm.add(realmFavoritedResource, update: .all)
            }
        }
        catch let error {
            assertionFailure(error.localizedDescription)
            return
        }
        
        resourceFavorited.accept(value: resourceId)
    }
    
    func removeFromFavorites(resourceId: String) {
        
        removeFromFavorites(realm: realmDatabase.mainThreadRealm, resourceId: resourceId)
    }
    
    func removeFromFavorites(realm: Realm, resourceId: String) {
                
        guard let favoritedResource = realm.object(ofType: RealmFavoritedResource.self, forPrimaryKey: resourceId) else {
            return
        }
        
        do {
            try realm.write {
                realm.delete(favoritedResource)
            }
        }
        catch let error {
            assertionFailure(error.localizedDescription)
            return
        }
        
        flattenSortOrder(realm: realm, startSortOrder: 0)
        
        resourceUnfavorited.accept(value: resourceId)
    }
    
    func setSortOrder(resourceId: String, newSortOrder: Int) {
        
        guard newSortOrder >= 0 else {
            assertionFailure("Invalid sortOrder.  Must be 0 or greater.")
            return
        }
        
        let realm: Realm = realmDatabase.mainThreadRealm
        
        guard let favoritedResourceToSort: RealmFavoritedResource = realm.object(ofType: RealmFavoritedResource.self, forPrimaryKey: resourceId) else {
            assertionFailure("resource does not exist")
            return
        }
        
        let currentSortOrder: Int = favoritedResourceToSort.sortOrder
        guard currentSortOrder != newSortOrder else {
            assertionFailure("current sortOrder: \(currentSortOrder) is equal to new sortOrder: \(newSortOrder)")
            return
        }
        
        let movedForward: Bool = currentSortOrder < newSortOrder
        let movedBackward: Bool = currentSortOrder > newSortOrder
        
        do {
            try realm.write {
                favoritedResourceToSort.sortOrder = -1
            }
        }
        catch let error {
            assertionFailure(error.localizedDescription)
            return
        }
        
        if movedBackward {
            
            let favorites: [RealmFavoritedResource] = Array(realm.objects(RealmFavoritedResource.self).filter("sortOrder >= \(newSortOrder)").sorted(byKeyPath: "sortOrder"))
            
            var nextSortOrder: Int = newSortOrder + 1
            
            do {
                try realm.write {
                    for favorite in favorites {
                        favorite.sortOrder = nextSortOrder
                        nextSortOrder += 1
                    }
                }
            }
            catch let error {
                assertionFailure(error.localizedDescription)
                return
            }
        }
        else if movedForward {
            
            let favorites: [RealmFavoritedResource] = Array(realm.objects(RealmFavoritedResource.self).filter("sortOrder >= \(currentSortOrder)").sorted(byKeyPath: "sortOrder"))
            
            var sortOrder: Int = currentSortOrder
            
            do {
                try realm.write {
                                        
                    for favorite in favorites {
                                                
                        favorite.sortOrder = sortOrder
                        sortOrder += 1
                        
                        if sortOrder == newSortOrder {
                            sortOrder += 1
                        }
                    }
                }
            }
            catch let error {
                assertionFailure(error.localizedDescription)
                return
            }
        }
        
        do {
            try realm.write {
                favoritedResourceToSort.sortOrder = newSortOrder
            }
        }
        catch let error {
            assertionFailure(error.localizedDescription)
            return
        }
        
        resourceSorted.accept(value: resourceId)
    }
    
    private func flattenSortOrder(realm: Realm, startSortOrder: Int) -> Error? {
        
        let sortedFavorites: [RealmFavoritedResource] = Array(realm.objects(RealmFavoritedResource.self).sorted(byKeyPath: "sortOrder"))
        
        var index: Int = startSortOrder
        
        do {
            try realm.write {
                
                for favorite in sortedFavorites {
                    favorite.sortOrder = index
                    index += 1
                }
            }
        }
        catch let error {
            return error
        }
        
        return nil
    }
    
    func bulkDeleteFavoritedResources(realm: Realm, resourceIds: [String]) -> Error? {
        
        var favoritedResourcesToDelete: [RealmFavoritedResource] = Array()
        
        for resourceId in resourceIds {
            if let realmFavoritedResource = realm.object(ofType: RealmFavoritedResource.self, forPrimaryKey: resourceId) {
                favoritedResourcesToDelete.append(realmFavoritedResource)
            }
        }
        
        guard !favoritedResourcesToDelete.isEmpty else {
            return nil
        }
        
        do {
            try realm.write {
                realm.delete(favoritedResourcesToDelete)
            }
        }
        catch let error {
            return error
        }
        
        return flattenSortOrder(realm: realm, startSortOrder: 0)
    }
}
