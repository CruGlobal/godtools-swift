//
//  RealmLanguagesCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmLanguagesCache {
    
    private let realmDatabase: RealmDatabase
    
    required init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getLanguages() -> [RealmLanguage] {
        return getLanguages(realm: realmDatabase.mainThreadRealm)
    }
    
    func getLanguages(realm: Realm) -> [RealmLanguage] {
        return Array(realm.objects(RealmLanguage.self))
    }
    
    func getLanguage(id: String) -> RealmLanguage? {
        return getLanguage(realm: realmDatabase.mainThreadRealm, id: id)
    }
    
    func getLanguage(realm: Realm, id: String) -> RealmLanguage? {
        return realm.object(ofType: RealmLanguage.self, forPrimaryKey: id)
    }
    
    func getLanguage(code: String) -> RealmLanguage? {
        return getLanguage(realm: realmDatabase.mainThreadRealm, code: code)
    }
    
    func getLanguage(realm: Realm, code: String) -> RealmLanguage? {
        
        guard !code.isEmpty else {
            return nil
        }
        
        let lowercasedCode: String = code.lowercased()
        
        return realm.objects(RealmLanguage.self).filter(NSPredicate(format: "code".appending(" = [c] %@"), lowercasedCode)).first
    }
}
