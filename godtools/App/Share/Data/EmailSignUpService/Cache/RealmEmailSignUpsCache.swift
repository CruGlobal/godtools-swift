//
//  RealmEmailSignUpsCache.swift
//  godtools
//
//  Created by Levi Eggert on 12/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

final class RealmEmailSignUpsCache {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func emailIsRegistered(email: String) throws -> Bool {
        return try getEmailSignUp(email: email)?.isRegistered ?? false
    }
    
    func getEmailSignUp(email: String) throws -> EmailSignUp? {
        
        let realm = try realmDatabase.openRealm()
        
        guard let realmEmailSignUp = realm.object(ofType: RealmEmailSignUp.self, forPrimaryKey: email) else {
            return nil
        }
        
        return realmEmailSignUp.toModel()
    }
    
    func getEmailSignUps() throws -> [EmailSignUp] {
        let realm: Realm = try realmDatabase.openRealm()
        let realmEmailSignUps: [RealmEmailSignUp] = Array(realm.objects(RealmEmailSignUp.self))
        return realmEmailSignUps.map({ $0.toModel() })
    }
    
    func cacheEmailSignUp(emailSignUp: EmailSignUp) {
        
        realmDatabase.write.serialAsync { result in
            
            switch result {
            case .success(let realm):
                
                let realmEmailSignUp: RealmEmailSignUp
                
                if let existingRealmEmailSignUp = realm.object(ofType: RealmEmailSignUp.self, forPrimaryKey: emailSignUp.email) {
                    realmEmailSignUp = existingRealmEmailSignUp
                }
                else {
                    realmEmailSignUp = RealmEmailSignUp()
                }
                
                realmEmailSignUp.mapFrom(model: emailSignUp)
                
                do {
                    try realm.write {
                        realm.add(realmEmailSignUp, update: .all)
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
