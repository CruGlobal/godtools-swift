//
//  RealmRegisteredEmailsCache.swift
//  godtools
//
//  Created by Levi Eggert on 12/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmRegisteredEmailsCache: RegisteredEmailsCacheType {
    
    private let realmDatabase: RealmDatabase
    
    required init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func storeRegisteredEmail(model: RegisteredEmailModel) {
        
        realmDatabase.background { [ weak self] (realm: Realm) in
           
            guard let cache = self else {
                return
            }
                        
            if let existingRegisteredEmail: RealmRegisteredEmailModel = cache.getRegisteredEmail(realm: realm, email: model.email) {
                
                cache.updateExistingRegisteredEmail(
                    realm: realm,
                    existingRegisteredEmail: existingRegisteredEmail,
                    fromModel: model
                )
            }
            else {
                
                cache.addNewRegisteredEmail(
                    realm: realm,
                    model: model
                )
            }
        }
    }
    
    func getRegisteredEmail(email: String) -> RegisteredEmailModel? {
        
        guard let realmRegisteredEmail = getRegisteredEmail(realm: realmDatabase.mainThreadRealm, email: email) else {
            return nil
        }
        
        return RegisteredEmailModel(model: realmRegisteredEmail)
    }
    
    private func updateExistingRegisteredEmail(realm: Realm, existingRegisteredEmail: RealmRegisteredEmailModel, fromModel: RegisteredEmailModel) {
        
        do {
            try realm.write {
                existingRegisteredEmail.firstName = fromModel.firstName
                existingRegisteredEmail.lastName = fromModel.lastName
                existingRegisteredEmail.isRegisteredWithRemoteApi = fromModel.isRegisteredWithRemoteApi
            }
        }
        catch let error {
            assertionFailure(error.localizedDescription)
            return
        }
    }
    
    private func addNewRegisteredEmail(realm: Realm, model: RegisteredEmailModel) {
        
        guard getRegisteredEmail(realm: realm, email: model.email) == nil else {
            return
        }
        
        let realmRegisteredEmail = RealmRegisteredEmailModel()
        realmRegisteredEmail.mapFrom(model: model)
        
        do {
            try realm.write {
                realm.add(realmRegisteredEmail, update: .all)
            }
        }
        catch let error {
            assertionFailure(error.localizedDescription)
            return
        }
    }
    
    private func getRegisteredEmail(realm: Realm, email: String) -> RealmRegisteredEmailModel? {
        
        guard !email.isEmpty else {
            return nil
        }
        
        if let realmRegisteredEmail = realm.objects(RealmRegisteredEmailModel.self).filter("email = '\(email)'").first {
            return realmRegisteredEmail
        }
        
        return nil
    }
}
