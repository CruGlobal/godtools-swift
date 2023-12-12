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
    
    func storePrimaryLanguage(id: String, languageId: String) -> Result<RealmToolSettings, Error> {
     
        let realm: Realm = realmDatabase.openRealm()
        
        let toolSettings: RealmToolSettings = realm.object(ofType: RealmToolSettings.self, forPrimaryKey: id) ?? RealmToolSettings()
        
        toolSettings.id = id
        toolSettings.primaryLanguageId = languageId
        
        do {
            
            try realm.write {
                realm.add(toolSettings, update: .all)
            }
            
            return .success(toolSettings)
        }
        catch let error {
            return .failure(error)
        }
    }
    
    func storeParallelLanguage(id: String, languageId: String) -> Result<RealmToolSettings, Error> {
        
        let realm: Realm = realmDatabase.openRealm()
        
        let toolSettings: RealmToolSettings = realm.object(ofType: RealmToolSettings.self, forPrimaryKey: id) ?? RealmToolSettings()
        
        toolSettings.id = id
        toolSettings.parallelLanguageId = languageId
        
        do {
            
            try realm.write {
                realm.add(toolSettings, update: .all)
            }
            
            return .success(toolSettings)
        }
        catch let error {
            return .failure(error)
        }
    }
}
