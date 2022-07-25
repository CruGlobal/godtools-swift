//
//  RealmTranslationsCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class RealmTranslationsCache {
    
    private let realmDatabase: RealmDatabase
        
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getRealmTranslation(id: String) -> RealmTranslation? {
        
        return realmDatabase.mainThreadRealm.object(ofType: RealmTranslation.self, forPrimaryKey: id)
    }
    
    func getTranslation(id: String) -> TranslationModel? {
        
        guard let realmTranslation = realmDatabase.mainThreadRealm.object(ofType: RealmTranslation.self, forPrimaryKey: id) else {
            return nil
        }
        
        return TranslationModel(realmTranslation: realmTranslation)
    }
}
