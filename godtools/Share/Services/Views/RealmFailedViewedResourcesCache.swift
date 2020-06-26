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
    
    private let realmDatabase: RealmDatabase
    
    required init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func cacheFailedViewedResource(resourceId: String, incrementFailedViewCountBy: Int) {
             
        realmDatabase.background { (realm: Realm) in
                                                 
            if let existingFailedViewedResource = realm.object(ofType: RealmFailedViewedResource.self, forPrimaryKey: resourceId) {
                
                do {
                    try realm.write {
                        existingFailedViewedResource.failedViewsCount += incrementFailedViewCountBy
                    }
                }
                catch let error {
                    assertionFailure(error.localizedDescription)
                }
            }
            else {
                
                let newFailedViewedResource: RealmFailedViewedResource = RealmFailedViewedResource()
                newFailedViewedResource.resourceId = resourceId
                newFailedViewedResource.failedViewsCount = 1
                
                do {
                    try realm.write {
                        realm.add(newFailedViewedResource)
                    }
                }
                catch let error {
                    assertionFailure(error.localizedDescription)
                }
            }
        }
    }
    
    func getCachedFailedViewedResources(completeOnMain: @escaping ((_ failedViewedResources: [FailedViewedResourceModel]) -> Void)) {
        realmDatabase.background { (realm: Realm) in
            
            let realmFailedViewedResources: [RealmFailedViewedResource] = Array(realm.objects(RealmFailedViewedResource.self))
            let failedViewedResources: [FailedViewedResourceModel] = realmFailedViewedResources.map({FailedViewedResourceModel(realmModel: $0)})
            
            DispatchQueue.main.async {
                completeOnMain(failedViewedResources)
            }
        }
    }
    
    func deleteFailedViewedResourceFromCache(resourceId: String) {
        realmDatabase.background { (realm: Realm) in
            guard let object = realm.object(ofType: RealmFailedViewedResource.self, forPrimaryKey: resourceId) else {
                return
            }
            do {
                try realm.write {
                    realm.delete(object)
                }
            }
            catch let error {
                assertionFailure(error.localizedDescription)
            }
        }
    }
}
