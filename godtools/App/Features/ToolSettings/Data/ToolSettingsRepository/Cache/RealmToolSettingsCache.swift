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
    
    private func getToolSettingsElseNew(realm: Realm, id: String) -> RealmToolSettings {
        
        let toolSettings: RealmToolSettings
        
        if let existingToolSettings = realm.object(ofType: RealmToolSettings.self, forPrimaryKey: id) {
            toolSettings = existingToolSettings
        }
        else {
            toolSettings = RealmToolSettings()
            toolSettings.id = id
        }
        
        return toolSettings
    }
    
    func storePrimaryLanguage(id: String, languageId: String) -> Result<RealmToolSettings, Error> {
     
        let realm: Realm = realmDatabase.openRealm()
        
        let toolSettings: RealmToolSettings = getToolSettingsElseNew(realm: realm, id: id)

        do {
            
            try realm.write {
                      
                toolSettings.primaryLanguageId = languageId
                
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
        
        let toolSettings: RealmToolSettings = getToolSettingsElseNew(realm: realm, id: id)
                
        do {
            
            try realm.write {
                
                toolSettings.parallelLanguageId = languageId
                
                realm.add(toolSettings, update: .all)
            }
            
            return .success(toolSettings)
        }
        catch let error {
            return .failure(error)
        }
    }
    
    func deletePrimaryLanguage(id: String) -> Result<Void, Error> {
        
        let realm: Realm = realmDatabase.openRealm()
        
        guard let toolSettings = getToolSettings(id: id) else {
            return .success(())
        }

        do {
            
            try realm.write {
                      
                toolSettings.primaryLanguageId = nil
                
                realm.add(toolSettings, update: .all)
            }
            
            return .success(())
        }
        catch let error {
            return .failure(error)
        }
    }
    
    func deleteParallelLanguage(id: String) -> Result<Void, Error> {
        
        let realm: Realm = realmDatabase.openRealm()
        
        guard let toolSettings = getToolSettings(id: id) else {
            return .success(())
        }

        do {
            
            try realm.write {
                      
                toolSettings.parallelLanguageId = nil
                
                realm.add(toolSettings, update: .all)
            }
            
            return .success(())
        }
        catch let error {
            return .failure(error)
        }
    }
}
