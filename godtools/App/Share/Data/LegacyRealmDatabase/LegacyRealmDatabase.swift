//
//  LegacyRealmDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine
import RepositorySync

@available(*, deprecated)
class LegacyRealmDatabase {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    private var config: Realm.Configuration {
        return realmDatabase.databaseConfig.config
    }

    func openRealm() -> Realm {
        
        return try! Realm(configuration: config)
    }
    
    func background(async: @escaping ((_ realm: Realm) -> Void)) {
                
        realmDatabase
            .write
            .serialAsync { result in
                
                let asyncRealm: Realm
                
                switch result {
                case .success(let realm):
                    asyncRealm = realm
                case .failure(let error):
                    assertionFailure("RealmDatabase: Did fail to initialize background realm with error: \(error.localizedDescription) ")
                    asyncRealm = try! Realm(configuration: self.config)
                }
                
                async(asyncRealm)
            }
    }
}
