//
//  RealmEmailSignUpsCache.swift
//  godtools
//
//  Created by Levi Eggert on 12/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmEmailSignUpsCache {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func emailIsRegistered(email: String) -> Bool {
        return getEmailSign(email: email)?.isRegistered ?? false
    }
    
    func getEmailSign(email: String) -> EmailSignUpModel? {
        
        guard let realmEmailSignUp = realmDatabase.openRealm().object(ofType: RealmEmailSignUp.self, forPrimaryKey: email) else {
            return nil
        }
        
        return EmailSignUpModel(model: realmEmailSignUp)
    }
    
    func cacheEmailSignUp(emailSignUp: EmailSignUpModel) {
          
        let realm: Realm = realmDatabase.openRealm()
        
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
    }
}
