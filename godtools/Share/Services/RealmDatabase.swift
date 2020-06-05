//
//  RealmDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmDatabase {
    
    // TODO: This static variable needs to be removed once Realm is injected properly
    // into GTDataManager. ~Levi
    static var sharedMainThreadRealm: Realm!
    
    private static let schemaVersion: UInt64 = 13
    
    let mainThreadRealm: Realm
    
    required init() {
        
        let config = RealmDatabase.createConfig
        
        do {
            mainThreadRealm = try Realm(configuration: config)
        }
        catch let error {
            assertionFailure("RealmDatabase: Did fail to initialize realm with error: \(error.localizedDescription) ")
            mainThreadRealm = try! Realm(configuration: config)
        }
        
        RealmDatabase.sharedMainThreadRealm = mainThreadRealm
    }
    
    private static var createConfig: Realm.Configuration  {
        return Realm.Configuration(
            schemaVersion: RealmDatabase.schemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    migration.enumerateObjects(ofType: DownloadedResource.className(), { (old, new) in
                        new!["aboutBannerRemoteId"] = ""
                    })
                }
                
                if oldSchemaVersion < 2 {
                    // removes Language.localizedName(), happens automatically, nothing to do here
                }
                
                if oldSchemaVersion < 3 {
                    migration.enumerateObjects(ofType: FollowUp.className(), { (old, new) in
                        new!["responseStatusCode"] = nil
                        new!["retryCount"] = 0
                        new!["createdAtTime"] = NSDate(timeIntervalSince1970: 1)
                    })
                }
                
                if oldSchemaVersion < 4 {
                    migration.enumerateObjects(ofType: DownloadedResource.className(), { (old, new) in
                        new!["descr"] = nil
                    })
                }
                
                if oldSchemaVersion < 5 {
                    migration.enumerateObjects(ofType: Language.className(), { (old, new) in
                        let stringId = old!["remoteId"] as! String
                        
                        if stringId == "38" {
                            migration.delete(old!)
                        }
                    })
                }
                
                if oldSchemaVersion < 6 {
                    migration.enumerateObjects(ofType: Language.className(), { (old, new) in
                        if let code = old?["code"] as? String {
                            new!["direction"] = ["ar", "he", "ur", "fa"].contains(code) ? "rtl" : "ltr"
                        }
                    })
                }
                
                if oldSchemaVersion < 8 {
                    migration.enumerateObjects(ofType: Translation.className(), { (old, new) in
                        // Nothing to do!
                        // Realm will automatically detect new properties and removed properties
                        // And will update the schema on disk automatically
                    })
                }
                if oldSchemaVersion < 9 {
                    migration.enumerateObjects(ofType: DownloadedResource.className(), { (old, new) in
                        new!["toolType"] = "tract"
                    })
                }
                if oldSchemaVersion < 10 {
                    migration.enumerateObjects(ofType: Language.className(), { (old, new) in
                        // Nothing to do!
                        // Realm will automatically detect new properties and removed properties
                        // And will update the schema on disk automatically
                    })
                }

                if oldSchemaVersion < 10 {
                    migration.enumerateObjects(ofType: DownloadedResource.className(), { (old, new) in
                        // Nothing to do!
                        // Realm will automatically detect new properties and removed properties
                        // And will update the schema on disk automatically
                    })
                }
        })
    }
}
