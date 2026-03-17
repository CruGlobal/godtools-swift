//
//  RealmUserToolSettingsCache.swift
//  godtools
//
//  Created by Rachael Skeath on 5/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmUserToolSettingsCache {
    
    private let realmDatabase: LegacyRealmDatabase
    
    init(realmDatabase: LegacyRealmDatabase) {
        self.realmDatabase = realmDatabase
    }
    
    func storeUserToolSettings(dataModel: UserToolSettingsDataModel) {
        
        let realm: Realm = realmDatabase.openRealm()
        
        let realmToolSettings = RealmUserToolSettings()
        realmToolSettings.mapFrom(dataModel: dataModel)
        
        do {
            
            try realm.write {
                realm.add(realmToolSettings, update: .modified)
            }
        }
        catch let error {
            print(error)
        }
    }
        
    func getUserToolSettings(toolId: String) -> UserToolSettingsDataModel? {
        
        let realm: Realm = realmDatabase.openRealm()
        
        guard let realmToolSettings = realm.object(ofType: RealmUserToolSettings.self, forPrimaryKey: toolId) else {
            return nil
        }
        
        return UserToolSettingsDataModel(realmObject: realmToolSettings)
    }
    
    func getUserToolSettingsPublisher(toolId: String) -> AnyPublisher<UserToolSettingsDataModel?, Never> {
        
        return Just(getUserToolSettings(toolId: toolId))
            .eraseToAnyPublisher()
    }
}
