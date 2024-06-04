//
//  RealmToolSettingsCache.swift
//  godtools
//
//  Created by Rachael Skeath on 5/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmToolSettingsCache {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        self.realmDatabase = realmDatabase
    }
    
    func storeToolSettings(dataModel: ToolSettingsDataModel) {
        
        let realm: Realm = realmDatabase.openRealm()
        
        let realmToolSettings = RealmToolSettings()
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
        
    func getToolSettings(toolId: String) -> ToolSettingsDataModel? {
        
        let realm: Realm = realmDatabase.openRealm()
        
        guard let realmToolSettings = realm.object(ofType: RealmToolSettings.self, forPrimaryKey: toolId) else {
            return nil
        }
        
        return ToolSettingsDataModel(realmObject: realmToolSettings)
    }
    
    func getToolSettingsPublisher(toolId: String) -> AnyPublisher<ToolSettingsDataModel?, Never> {
        
        return Just(getToolSettings(toolId: toolId))
            .eraseToAnyPublisher()
    }
}
