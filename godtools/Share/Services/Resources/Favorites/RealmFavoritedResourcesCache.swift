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
    
    required init(realmDatabase: RealmDatabase) {
        
        mainThreadRealm = realmDatabase.mainThreadRealm
    }
    
    func getCachedFavoritedResources(complete: @escaping ((_ favoritedResources: [RealmFavoritedResource]) -> Void)) {
        
        DispatchQueue.main.async { [weak self] in
            
            if let favoritedResources = self?.mainThreadRealm.objects(RealmFavoritedResource.self) {
                complete(Array(favoritedResources))
            }
            else {
                complete([])
            }
        }
    }
    
    func addResourceToFavorites(resourceId: String, complete: @escaping ((_ error: Error?) -> Void)) {
        
        DispatchQueue.main.async { [weak self] in
            
            var cacheError: Error?
            
            let favoritedResource = RealmFavoritedResource()
            favoritedResource.resourceId = resourceId
            
            do {
                try self?.mainThreadRealm.write {
                    self?.mainThreadRealm.add(favoritedResource)
                }
            }
            catch let error {
                cacheError = error
            }
            
            complete(cacheError)
        }
    }
    
    func removeResourceFromFavorites(resourceId: String, complete: @escaping ((_ error: Error?) -> Void)) {
        
        DispatchQueue.main.async { [weak self] in
               
            guard let objects = self?.mainThreadRealm.objects(RealmFavoritedResource.self).filter("resourceId = '\(resourceId)'") else {
                complete(nil)
                return
            }
            
            guard !objects.isEmpty else {
                complete(nil)
                return
            }
            
            var cacheError: Error?
            
            do {
                try self?.mainThreadRealm.write {
                    self?.mainThreadRealm.delete(objects)
                }
            }
            catch let error {
                cacheError = error
            }
            
            complete(cacheError)
        }
    }
}
