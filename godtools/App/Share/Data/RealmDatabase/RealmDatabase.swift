//
//  RealmDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmDatabase {
    
    private let databaseConfiguration: RealmDatabaseConfiguration
    private let config: Realm.Configuration
    private let realmInstanceCreator: RealmInstanceCreator
    
    init(databaseConfiguration: RealmDatabaseConfiguration, realmInstanceCreationType: RealmInstanceCreationType = .alwaysCreatesANewRealmInstance) {
        
        self.databaseConfiguration = databaseConfiguration
        config = databaseConfiguration.getRealmConfig()
        realmInstanceCreator = RealmInstanceCreator(config: config, creationType: realmInstanceCreationType)
    }

    func openRealm() -> Realm {
        
        return realmInstanceCreator.createRealm()
    }
    
    func background(async: @escaping ((_ realm: Realm) -> Void)) {
                
        realmInstanceCreator.createBackgroundRealm(async: async)
    }
}
