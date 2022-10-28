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
        return getEmailSignUpOnMainThread(email: email)?.isRegistered ?? false
    }
    
    func getEmailSignUpOnMainThread(email: String) -> EmailSignUpModel? {
        
        return getEmailSignUp(realm: realmDatabase.mainThreadRealm, email: email)
    }
    
    func getEmailSignUp(realm: Realm, email: String) -> EmailSignUpModel? {
        
        guard !email.isEmpty else {
            return nil
        }
        
        guard let realmEmailSignUp = realm.object(ofType: RealmEmailSignUp.self, forPrimaryKey: email) else {
            return nil
        }
        
        return EmailSignUpModel(model: realmEmailSignUp)
    }
    
    func cacheEmailSignUp(emailSignUp: EmailSignUpModel) {
                   
        let realm: Realm = realmDatabase.mainThreadRealm
        
        if let cachedEmailSignUp = realm.object(ofType: RealmEmailSignUp.self, forPrimaryKey: emailSignUp.email) {
            
            updateExistingEmailSignUp(
                realm: realm,
                cachedEmailSignUp: cachedEmailSignUp,
                updateFromEmailSignUp: emailSignUp
            )
        }
        else {
            
            cacheNewEmailSignUp(
                realm: realm,
                emailSignUp: emailSignUp
            )
        }
    }
    
    private func cacheNewEmailSignUp(realm: Realm, emailSignUp: EmailSignUpModel) {
        
        guard getEmailSignUp(realm: realm, email: emailSignUp.email) == nil else {
            return
        }
        
        let realmEmailSignUp: RealmEmailSignUp = RealmEmailSignUp()
        realmEmailSignUp.mapFrom(model: emailSignUp, ignorePrimaryKey: false)
        
        do {
            try realm.write {
                realm.add(realmEmailSignUp)
            }
        }
        catch let error {
            assertionFailure(error.localizedDescription)
        }
    }
    
    private func updateExistingEmailSignUp(realm: Realm, cachedEmailSignUp: RealmEmailSignUp, updateFromEmailSignUp: EmailSignUpModel) {
        
        do {
            try realm.write {
                cachedEmailSignUp.mapFrom(model: updateFromEmailSignUp, ignorePrimaryKey: true)
            }
        }
        catch let error {
            assertionFailure(error.localizedDescription)
        }
    }
}
