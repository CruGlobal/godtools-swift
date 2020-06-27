//
//  FailedResourceViewsCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class FailedResourceViewsCache {
    
    private let realmDatabase: RealmDatabase
    
    required init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getFailedResourceViews() -> [FailedResourceViewModel] {
        let realm: Realm = realmDatabase.mainThreadRealm
        let realmFailedResourceViews: [RealmFailedResourceView] = Array(realm.objects(RealmFailedResourceView.self))
        return realmFailedResourceViews.map({FailedResourceViewModel(model: $0)})
    }
    
    func cacheFailedResourceViews(resourceIds: [String], incrementFailedViewCountBy: Int) {
             
        realmDatabase.background { (realm: Realm) in
                
            do {
                try realm.write {

                    for resourceId in resourceIds {
                        
                        if let existingFailedResourceView = realm.object(ofType: RealmFailedResourceView.self, forPrimaryKey: resourceId) {
                            existingFailedResourceView.failedViewsCount += incrementFailedViewCountBy
                        }
                        else {
                            let newFailedResourceView: RealmFailedResourceView = RealmFailedResourceView()
                            newFailedResourceView.resourceId = resourceId
                            newFailedResourceView.failedViewsCount = 1
                            realm.add(newFailedResourceView)
                        }
                    }
                }
            }
            catch let error {
                assertionFailure(error.localizedDescription)
            }
        }
    }
    
    func deleteFailedResourceViews(resourceIds: [String]) {
        
        realmDatabase.background { (realm: Realm) in
            
            var failedResourceViews: [RealmFailedResourceView] = Array()
            
            for resourceId in resourceIds {
                if let failedResourceView = realm.object(ofType: RealmFailedResourceView.self, forPrimaryKey: resourceId) {
                    failedResourceViews.append(failedResourceView)
                }
            }
            
            guard !failedResourceViews.isEmpty else {
                return
            }
            
            do {
                try realm.write {
                    realm.delete(failedResourceViews)
                }
            }
            catch let error {
                assertionFailure(error.localizedDescription)
            }
        }
    }
}
