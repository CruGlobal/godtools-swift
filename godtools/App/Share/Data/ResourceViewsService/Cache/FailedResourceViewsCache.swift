//
//  FailedResourceViewsCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

final class FailedResourceViewsCache {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getFailedResourceViews() throws -> [ResourceViewsDataModel] {
        
        let realm: Realm = try realmDatabase.openRealm()
        let realmResourceViews: [RealmResourceView] = Array(realm.objects(RealmResourceView.self))
        
        return realmResourceViews.map({ $0.toModel() })
    }
    
    func cacheFailedResourceViews(resourceViews: [ResourceViewsDataModel]) {
             
        guard !resourceViews.isEmpty else {
            return
        }
        
        realmDatabase.write.serialAsync { (result: Result<Realm, Error>) in
            
            switch result {
            
            case .success(let realm):
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
                
            case .failure( _):
                break
            }
        }
    }
    
    func deleteFailedResourceViews(resourceViews: [ResourceViewsDataModel]) {
        
        guard !resourceViews.isEmpty else {
            return
        }
        
        realmDatabase.write.serialAsync { (result: Result<Realm, Error>) in
            
            switch result {
            
            case .success(let realm):
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
                
            case .failure( _):
                break
            }
        }
    }
}
