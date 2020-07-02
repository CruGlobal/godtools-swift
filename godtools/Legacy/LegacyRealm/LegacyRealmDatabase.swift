//
//  LegacyRealmDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 6/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class LegacyRealmDatabase {
        
    private static let schemaVersion: UInt64 = 14
        
    required init() {
            
        // NOTE: Should no longer be used.  Instead use RealmDatabase.swift.
    }
    
    var databaseExists: Bool {
        
        let fileManager: FileManager = FileManager.default
        let documentsPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
       
        do {
            let documentsContents: [String] = try fileManager.contentsOfDirectory(atPath: documentsPath)
            return documentsContents.contains("default.realm") || documentsContents.contains("default.realm.lock")
        }
        catch {
            return false
        }
    }
    
    func getMainThreadRealm() -> Realm? {
        
        let config: Realm.Configuration = LegacyRealmDatabase.createConfig
        let realm: Realm
        
        do {
            realm = try Realm(configuration: config)
            return realm
        }
        catch let error {
            assertionFailure(error.localizedDescription)
            return nil
        }
    }

    func deleteDatabase(realm: Realm) {
              
        let config: Realm.Configuration = LegacyRealmDatabase.createConfig
        
        do {
            try realm.write {
                realm.deleteAll()
            }
        }
        catch {

        }
        
        let fileManager: FileManager = FileManager.default
                
        if let realmURL = config.fileURL {
            
            let realmURLs: [URL] = [
                realmURL,
                realmURL.appendingPathExtension("lock"),
                realmURL.appendingPathExtension("note"),
                realmURL.appendingPathExtension("management")
            ]
            
            for URL in realmURLs {
                do {
                    try fileManager.removeItem(at: URL)
                } catch {

                }
            }
        }
    }

    private static var createConfig: Realm.Configuration  {
        
        return Realm.Configuration(
            schemaVersion: LegacyRealmDatabase.schemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                
                if oldSchemaVersion < 1 {
                    migration.enumerateObjects(ofType: DownloadedResource.className(), { (old, new) in
                        new!["aboutBannerRemoteId"] = ""
                    })
                }
                
                if oldSchemaVersion < 2 {
                    // removes Language.localizedName(), happens automatically, nothing to do here
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
        })
    }
}
