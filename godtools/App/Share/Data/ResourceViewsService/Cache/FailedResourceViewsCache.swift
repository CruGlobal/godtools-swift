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
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getFailedResourceViews() -> [ResourceViewModel] {
        
        let realm: Realm = realmDatabase.openRealm()
        let realmResourceViews: [RealmResourceView] = Array(realm.objects(RealmResourceView.self))
        
        return realmResourceViews.map({ResourceViewModel(model: $0)})
    }
    
    func cacheFailedResourceViews(resourceViews: [ResourceViewModel]) {
             
        guard !resourceViews.isEmpty else {
            return
        }
        
        realmDatabase.background { (realm: Realm) in
                
            do {
                try realm.write {

                    for resourceView in resourceViews {
                        
                        if let existingFailedResourceView = realm.object(ofType: RealmResourceView.self, forPrimaryKey: resourceView.resourceId) {
                            existingFailedResourceView.quantity += 1
                        }
                        else {
                            let newResourceView = RealmResourceView()
                            newResourceView.resourceId = resourceView.resourceId
                            newResourceView.quantity = 1
                            realm.add(newResourceView)
                        }
                    }
                }
            }
            catch let error {
                assertionFailure(error.localizedDescription)
            }
        }
    }
    
    func deleteFailedResourceViews(resourceViews: [ResourceViewModel]) {
        
        guard !resourceViews.isEmpty else {
            return
        }
        
        realmDatabase.background { (realm: Realm) in
            
            var realmResourceViewsToDelete: [RealmResourceView] = Array()
            
            for resourceView in resourceViews {
                if let realmResourceView = realm.object(ofType: RealmResourceView.self, forPrimaryKey: resourceView.resourceId) {
                    realmResourceViewsToDelete.append(realmResourceView)
                }
            }
            
            guard !realmResourceViewsToDelete.isEmpty else {
                return
            }
            
            do {
                try realm.write {
                    realm.delete(realmResourceViewsToDelete)
                }
            }
            catch let error {
                assertionFailure(error.localizedDescription)
            }
        }
    }
}
