//
//  RealmToolSettingsCache.swift
//  godtools
//
//  Created by Levi Eggert on 12/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmToolSettingsCache {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getToolSettings(id: String) -> RealmToolSettings? {
        
        let realm: Realm = realmDatabase.openRealm()
        
        let toolSettings: RealmToolSettings? = realm.object(ofType: RealmToolSettings.self, forPrimaryKey: id)
        
        return toolSettings
    }
    
    func getToolSettingsChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return realmDatabase.openRealm().objects(RealmToolSettings.self).objectWillChange
            .map { _ in
                Void()
            }
            .eraseToAnyPublisher()
    }
    
    func storePrimaryLanguagePublisher(id: String, languageId: String?) -> AnyPublisher<Void, Error> {
        
        return realmDatabase
            .writeObjectsPublisher { realm in
                
                let toolSettings: RealmToolSettings = self.realmDatabase.readObjectElseCreateNew(realm: realm, primaryKey: id)
                toolSettings.primaryLanguageId = languageId
                
                return [toolSettings]
            }
            .map { _ in
                Void()
            }
            .eraseToAnyPublisher()
    }
    
    func storeParallelLanguagePublisher(id: String, languageId: String?) -> AnyPublisher<Void, Error> {
        
        return realmDatabase
            .writeObjectsPublisher { realm in
                
                let toolSettings: RealmToolSettings = self.realmDatabase.readObjectElseCreateNew(realm: realm, primaryKey: id)
                toolSettings.parallelLanguageId = languageId
                
                return [toolSettings]
            }
            .map { _ in
                Void()
            }
            .eraseToAnyPublisher()
    }
    
    func deletePrimaryLanguagePublisher(id: String) -> AnyPublisher<Void, Error> {
        
        return storePrimaryLanguagePublisher(id: id, languageId: nil)
            .eraseToAnyPublisher()
    }
    
    func deleteParallelLanguagePublisher(id: String) -> AnyPublisher<Void, Error> {
        
        return storeParallelLanguagePublisher(id: id, languageId: nil)
            .eraseToAnyPublisher()
    }
}
