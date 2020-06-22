//
//  RealmFavoritedResourcesCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmFavoritedResourcesCache {
        
    private let realmDatabase: RealmDatabase
    
    required init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getFavoritedResources(complete: @escaping ((_ favoritedResources: [RealmFavoritedResource]) -> Void)) {
        realmDatabase.background { (realm: Realm) in
            let realmFavoritedResources: [RealmFavoritedResource] = Array(realm.objects(RealmFavoritedResource.self))
            complete(realmFavoritedResources)
        }
    }
    
    func isFavorited(resourceId: String, complete: @escaping ((_ isFavorited: Bool) -> Void)) {
        realmDatabase.background { (realm: Realm) in
            let realmFavoritedResource: RealmFavoritedResource? = realm.object(ofType: RealmFavoritedResource.self, forPrimaryKey: resourceId)
            let isFavorited: Bool = realmFavoritedResource != nil
            complete(isFavorited)
        }
    }
    
    func addToFavorites(resourceId: String, complete: @escaping ((_ error: Error?) -> Void)) {
        
        realmDatabase.background { [weak self] (realm: Realm) in
            
            if let error = self?.flattenSortOrder(realm: realm, startIndex: 1) {
                complete(error)
                return
            }
            
            let realmFavoritedResource = RealmFavoritedResource()
            realmFavoritedResource.resourceId = resourceId
            realmFavoritedResource.sortOrder = 0
            
            do {
                try realm.write {
                    realm.add(realmFavoritedResource, update: .all)
                }
            }
            catch let error {
                complete(error)
                return
            }
            
            complete(nil)
            
            print("\n Add To Favorites")
            self?.log(realm: realm)
        }
    }
    
    func removeFromFavorites(resourceId: String, complete: @escaping ((_ error: Error?) -> Void)) {
        
        realmDatabase.background { [weak self] (realm: Realm) in
                        
            if let realmFavoritedResource = realm.object(ofType: RealmFavoritedResource.self, forPrimaryKey: resourceId) {
                
                do {
                    try realm.write {
                        realm.delete(realmFavoritedResource)
                    }
                }
                catch let error {
                    complete(error)
                    return
                }
                
                if let error = self?.flattenSortOrder(realm: realm, startIndex: 0) {
                    complete(error)
                    return
                }
            }
            
            print("\n Remove From Favorites")
            self?.log(realm: realm)
            
            complete(nil)
        }
    }
    
    func setSortOrder(resourceId: String, newSortOrder: Int, complete: @escaping ((_ error: Error?) -> Void)) {
        
        guard newSortOrder >= 0 else {
            assertionFailure("Invalid sortOrder.  Must be 0 or greater.")
            complete(nil)
            return
        }
        
        realmDatabase.background { [weak self] (realm: Realm) in
                        
            guard let favoritedResourceToSort: RealmFavoritedResource = realm.object(ofType: RealmFavoritedResource.self, forPrimaryKey: resourceId) else {
                assertionFailure("resource does not exist")
                complete(nil)
                return
            }
            
            let currentSortOrder: Int = favoritedResourceToSort.sortOrder
            guard currentSortOrder != newSortOrder else {
                assertionFailure("current sortOrder: \(currentSortOrder) is equal to new sortOrder: \(newSortOrder)")
                complete(nil)
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
                complete(error)
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
                    complete(error)
                    return
                }
            }
            else if movedForward {
                
                let favorites: [RealmFavoritedResource] = Array(realm.objects(RealmFavoritedResource.self).filter("sortOrder >= \(currentSortOrder)").sorted(byKeyPath: "sortOrder"))
                
                var sortOrder: Int = currentSortOrder
                
                do {
                    try realm.write {
                        
                        print("\n update favorites: \(favorites)")
                        
                        for favorite in favorites {
                            
                            print("  favorite.resourceId: \(favorite.resourceId) set sortOrder \(favorite.sortOrder), to new sort order: \(sortOrder)")
                            
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
                    complete(error)
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
                complete(error)
                return
            }
            
            print("\n Set Favorite Sort Order")
            print("   resourceId: \(resourceId)")
            print("    current sort order: \(currentSortOrder)")
            print("    new sort order: \(newSortOrder)")
            print("    moved forward: \(movedForward)")
            print("    moved backward: \(movedBackward)")
            print("    favoritedResourceToSort.sortOrder: \(favoritedResourceToSort.sortOrder)")
            self?.log(realm: realm)
            
            complete(nil)
        }
    }
    
    private func flattenSortOrder(realm: Realm, startIndex: Int) -> Error? {
        
        let sortedFavorites: [RealmFavoritedResource] = Array(realm.objects(RealmFavoritedResource.self).sorted(byKeyPath: "sortOrder"))
        
        var index: Int = startIndex
        
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
    
    private func log(realm: Realm) {
        
        print("\n Sorted Favorites")
        let sortedFavorites: [RealmFavoritedResource] = Array(realm.objects(RealmFavoritedResource.self).sorted(byKeyPath: "sortOrder"))
        for favorite in sortedFavorites {
            
            print("   resourceId: \(favorite.resourceId)")
            print("     sortOrder: \(favorite.sortOrder)")
        }
    }
}
