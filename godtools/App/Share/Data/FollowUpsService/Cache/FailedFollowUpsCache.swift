//
//  FailedFollowUpsCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

final class FailedFollowUpsCache {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getFailedFollowUps() throws -> [FollowUpDataModel] {
        let realm: Realm = try realmDatabase.openRealm()
        let realmFollowUps: [RealmFollowUp] = Array(realm.objects(RealmFollowUp.self))
        return realmFollowUps.map({ $0.toModel() })
    }
    
    func cacheFailedFollowUps(followUps: [FollowUpDataModel]) {
           
        guard !followUps.isEmpty else {
            return
        }
        
        realmDatabase.write.serialAsync { result in
            
            switch result {
            
            case .success(let realm):
                
                let realmFollowUps: [RealmFollowUp] = followUps.map({
                    let realmFollowUp: RealmFollowUp = RealmFollowUp()
                    realmFollowUp.mapFrom(model: $0)
                    return realmFollowUp
                })
                
                do {
                    try realm.write {
                        realm.add(realmFollowUps)
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
    
    func deleteFollowUps(followUps: [FollowUpDataModel]) {
        
        guard !followUps.isEmpty else {
            return
        }
        
        realmDatabase.write.serialAsync { result in
            
            switch result {
            
            case .success(let realm):
                
                var realmFollowUpsToDelete: [RealmFollowUp] = Array()
                
                for followUp in followUps {
                    if let realmFollowUp = realm.object(ofType: RealmFollowUp.self, forPrimaryKey: followUp.id) {
                        realmFollowUpsToDelete.append(realmFollowUp)
                    }
                }
                
                guard !realmFollowUpsToDelete.isEmpty else {
                    return
                }
                
                do {
                    try realm.write {
                        realm.delete(realmFollowUpsToDelete)
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
