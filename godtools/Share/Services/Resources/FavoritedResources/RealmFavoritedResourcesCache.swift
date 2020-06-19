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
    
    let resourceFavorited: SignalValue<String> = SignalValue()
    let resourceUnfavorited: SignalValue<String> = SignalValue()
    
    required init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getFavoritedResources(completeOnMain: @escaping ((_ favoritedResources: [FavoritedResourceModel]) -> Void)) {
        realmDatabase.background { (realm: Realm) in
            let realmFavoritedResources: [RealmFavoritedResource] = Array(realm.objects(RealmFavoritedResource.self))
            let favoritedResources: [FavoritedResourceModel] = realmFavoritedResources.map({FavoritedResourceModel(model: $0)})
            DispatchQueue.main.async {
                completeOnMain(favoritedResources)
            }
        }
    }
    
    func isFavorited(resourceId: String, completeOnMain: @escaping ((_ isFavorited: Bool) -> Void)) {
        realmDatabase.background { (realm: Realm) in
            let realmFavoritedResource: RealmFavoritedResource? = realm.object(ofType: RealmFavoritedResource.self, forPrimaryKey: resourceId)
            let isFavorited: Bool = realmFavoritedResource != nil
            DispatchQueue.main.async {
                completeOnMain(isFavorited)
            }
        }
    }
    
    func toggleFavorited(resourceId: String) {
        isFavorited(resourceId: resourceId) { [weak self] (isFavorited: Bool) in
            if isFavorited {
                self?.removeResourceFromFavorites(resourceId: resourceId)
            }
            else {
                self?.addResourceToFavorites(resourceId: resourceId)
            }
        }
    }
    
    func addResourceToFavorites(resourceId: String) {
        realmDatabase.background { [weak self] (realm: Realm) in
            
            let realmFavoritedResource = RealmFavoritedResource()
            realmFavoritedResource.resourceId = resourceId
            
            do {
                try realm.write {
                    realm.add(realmFavoritedResource, update: .all)
                }
            }
            catch let error {
                assertionFailure(error.localizedDescription)
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.resourceFavorited.accept(value: resourceId)
            }
        }
    }
    
    func removeResourceFromFavorites(resourceId: String) {
        realmDatabase.background { [weak self] (realm: Realm) in
            
            if let realmFavoritedResource = realm.object(ofType: RealmFavoritedResource.self, forPrimaryKey: resourceId) {
                
                do {
                    try realm.write {
                        realm.delete(realmFavoritedResource)
                    }
                }
                catch let error {
                    assertionFailure(error.localizedDescription)
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.resourceUnfavorited.accept(value: resourceId)
            }
        }
    }
}
