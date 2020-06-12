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
    
    private let mainThreadRealm: Realm
    
    let resourceFavorited: SignalValue<String> = SignalValue()
    let resourceUnfavorited: SignalValue<String> = SignalValue()
    
    required init(realmDatabase: RealmDatabase) {
        
        mainThreadRealm = realmDatabase.mainThreadRealm
    }
    
    func getCachedFavoritedResources() -> [RealmFavoritedResource] {
        return Array(mainThreadRealm.objects(RealmFavoritedResource.self))
    }
    
    func isFavorited(resourceId: String) -> Bool {
        let objects = mainThreadRealm.objects(RealmFavoritedResource.self).filter("resourceId = '\(resourceId)'")
        return !objects.isEmpty
    }
    
    func changeFavorited(resourceId: String) {
                
        let resourceIsFavorited: Bool = isFavorited(resourceId: resourceId)
                
        if resourceIsFavorited {
            _ = removeResourceFromFavorites(resourceId: resourceId)
        }
        else {
            _ = addResourceToFavorites(resourceId: resourceId)
        }
    }
    
    func addResourceToFavorites(resourceId: String) -> Error? {
        
        let favoritedResource = RealmFavoritedResource()
        favoritedResource.resourceId = resourceId
        
        do {
            try mainThreadRealm.write {
                mainThreadRealm.add(favoritedResource)
                resourceFavorited.accept(value: resourceId)
            }
        }
        catch let error {
            return error
        }
        
        return nil
    }
    
    func removeResourceFromFavorites(resourceId: String) -> Error? {
        
        let objects = mainThreadRealm.objects(RealmFavoritedResource.self).filter("resourceId = '\(resourceId)'")
        
        guard !objects.isEmpty else {
            return nil
        }
                
        do {
            try mainThreadRealm.write {
                mainThreadRealm.delete(objects)
                resourceUnfavorited.accept(value: resourceId)
            }
        }
        catch let error {
            return error
        }
        
        return nil
    }
}
