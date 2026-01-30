//
//  RealmInstanceCreator.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmInstanceCreator {
    
    private let backgroundQueue: DispatchQueue = DispatchQueue(label: "realm.background_queue")
    private let config: Realm.Configuration
            
    init(config: Realm.Configuration) {
        
        self.config = config
    }
    
    func createRealm() -> Realm {
        
        return try! Realm(configuration: config)
    }
    
    func createBackgroundRealm(async: @escaping ((_ realm: Realm) -> Void)) {
             
        backgroundQueue.async {
            autoreleasepool {
                
                let realm: Realm
               
                do {
                    realm = try Realm(configuration: self.config)
                }
                catch let error {
                    assertionFailure("RealmDatabase: Did fail to initialize background realm with error: \(error.localizedDescription) ")
                    realm = try! Realm(configuration: self.config)
                }
                
                async(realm)
            }
        }
    }
}
