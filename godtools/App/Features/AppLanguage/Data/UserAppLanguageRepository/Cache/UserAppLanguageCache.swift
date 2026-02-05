//
//  RealmUserAppLanguageCache.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import Combine
import RealmSwift

class UserAppLanguageCache {
            
    let persistence: any Persistence<UserAppLanguageDataModel, UserAppLanguageDataModel>
    
    init(persistence: any Persistence<UserAppLanguageDataModel, UserAppLanguageDataModel>) {
                
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    func getSwiftPersistence() -> SwiftRepositorySyncPersistence<UserAppLanguageDataModel, UserAppLanguageDataModel, SwiftUserAppLanguage>? {
        return persistence as? SwiftRepositorySyncPersistence<UserAppLanguageDataModel, UserAppLanguageDataModel, SwiftUserAppLanguage>
    }
    
    var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    func getRealmPersistence() -> RealmRepositorySyncPersistence<UserAppLanguageDataModel, UserAppLanguageDataModel, RealmUserAppLanguage>? {
        return persistence as? RealmRepositorySyncPersistence<UserAppLanguageDataModel, UserAppLanguageDataModel, RealmUserAppLanguage>
    }
}

extension UserAppLanguageCache {
    
    func deleteLanguage(id: String) throws {
            
        if #available(iOS 17.4, *), let database = swiftDatabase {
            
            // TODO: Delete for swiftdatabase. ~Levi
        }
        else if let realmDatabase = realmDatabase {
            
            let realm: Realm = try realmDatabase.openRealm()
            
            let objectToDelete: RealmUserAppLanguage? = realmDatabase.read.object(realm: realm, id: id)
            
            if let objectToDelete = objectToDelete {
                
                try realmDatabase.write.realm(realm: realm, writeClosure: { realm in
                    
                    return WriteRealmObjects(
                        deleteObjects: [objectToDelete],
                        addObjects: []
                    )
                }, updatePolicy: .all)
            }
        }
    }
}
