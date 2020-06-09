//
//  RealmFailedViewedResourcesCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmFailedViewedResourcesCache {
    
    private let mainThreadRealm: Realm
    
    required init(mainThreadRealm: Realm) {
        
        self.mainThreadRealm = mainThreadRealm
    }
    
    func cacheFailedViewedResource(resourceId: String, incrementFailedViewCountBy: Int, complete: @escaping ((_ error: Error?) -> Void)) {
                
        DispatchQueue.main.async { [weak self] in
            
            var cacheError: Error?
            
            if let cachedFailedViewedResource = self?.cachedFailedViewedResource(resourceId: resourceId) {
                
                do {
                    try self?.mainThreadRealm.write {
                        cachedFailedViewedResource.failedViewsCount += incrementFailedViewCountBy
                    }
                }
                catch let error {
                    assertionFailure(error.localizedDescription)
                    cacheError = error
                }
            }
            else {
                
                let newFailedViewedResource: RealmFailedViewedResource = RealmFailedViewedResource()
                newFailedViewedResource.resourceId = resourceId
                newFailedViewedResource.failedViewsCount = 1
                
                do {
                    try self?.mainThreadRealm.write {
                        self?.mainThreadRealm.add(newFailedViewedResource)
                    }
                }
                catch let error {
                    assertionFailure(error.localizedDescription)
                    cacheError = error
                }
            }
            
            complete(cacheError)
        }
    }
    
    func cachedFailedViewedResources() -> [RealmFailedViewedResource] {
        
        return Array(mainThreadRealm.objects(RealmFailedViewedResource.self))
    }
    
    func cachedFailedViewedResource(resourceId: String) -> RealmFailedViewedResource? {
        
        let objects = mainThreadRealm.objects(RealmFailedViewedResource.self).filter("resourceId = '\(resourceId)'")
        
        if objects.count > 1 {
            assertionFailure("Count should never be greater than one because each FailedViewedResource has primary key resourceId.")
        }
        
        return objects.first
    }
    
    func deleteFailedViewedResourceFromCache(resourceId: String, complete: @escaping ((_ error: Error?) -> Void)) {
                
        DispatchQueue.main.async { [weak self] in
               
            guard let objects = self?.mainThreadRealm.objects(RealmFailedViewedResource.self).filter("resourceId = '\(resourceId)'") else {
                complete(nil)
                return
            }
            
            guard !objects.isEmpty else {
                complete(nil)
                return
            }
            
            do {
                try self?.mainThreadRealm.write {
                    self?.mainThreadRealm.delete(objects)
                    complete(nil)
                }
            }
            catch let error {
                assertionFailure(error.localizedDescription)
                complete(error)
            }
        }
    }
}
