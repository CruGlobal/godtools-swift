//
//  LanguagesCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class LanguagesCache {
    
    private let realmDatabase: RealmDatabase
    
    required init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getLanguages() -> [LanguageModel] {
        return getLanguages(realm: realmDatabase.mainThreadRealm)
    }
    
    func getLanguages(realm: Realm) -> [LanguageModel] {
        let realmLanguages: [RealmLanguage] = Array(realm.objects(RealmLanguage.self))
        return realmLanguages.map({LanguageModel(realmLanguage: $0)})
    }
    
    func getLanguage(id: String) -> LanguageModel? {
        return getLanguage(realm: realmDatabase.mainThreadRealm, id: id)
    }
    
    func getLanguage(realm: Realm, id: String) -> LanguageModel? {
        let realm: Realm = realmDatabase.mainThreadRealm
        if let realmLanguage = realm.object(ofType: RealmLanguage.self, forPrimaryKey: id) {
            return LanguageModel(realmLanguage: realmLanguage)
        }
        return nil
    }
    
    func getLanguage(code: String) -> LanguageModel? {
        return getLanguage(realm: realmDatabase.mainThreadRealm, code: code)
    }
    
    func getLanguage(realm: Realm, code: String) -> LanguageModel? {
        let realm: Realm = realmDatabase.mainThreadRealm
        if let realmLanguage = realm.objects(RealmLanguage.self).filter("code = '\(code)'").first {
            return LanguageModel(realmLanguage: realmLanguage)
        }
        return nil
    }
}
