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
        let realm: Realm = realmDatabase.mainThreadRealm
        let realmLanguages: [RealmLanguage] = Array(realm.objects(RealmLanguage.self))
        return realmLanguages.map({LanguageModel(realmLanguage: $0)})
    }
    
    func getLanguage(id: String) -> LanguageModel? {
        let realm: Realm = realmDatabase.mainThreadRealm
        if let realmLanguage = realm.object(ofType: RealmLanguage.self, forPrimaryKey: id) {
            return LanguageModel(realmLanguage: realmLanguage)
        }
        return nil
    }
}
