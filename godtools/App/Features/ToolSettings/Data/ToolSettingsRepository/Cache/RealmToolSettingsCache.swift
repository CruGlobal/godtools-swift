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
}
