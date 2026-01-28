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

class LegacyRealmDatabase {
    
    private let databaseConfiguration: RealmDatabaseConfiguration
    private let config: Realm.Configuration
    private let realmInstanceCreator: RealmInstanceCreator
    
    init(databaseConfiguration: RealmDatabaseConfiguration) {
        
        self.databaseConfiguration = databaseConfiguration
        config = databaseConfiguration.getRealmConfig()
        realmInstanceCreator = RealmInstanceCreator(config: config)
        
        _ = checkForUnsupportedFileFormatVersionAndDeleteRealmFilesIfNeeded(config: config)
    }
    
    private func checkForUnsupportedFileFormatVersionAndDeleteRealmFilesIfNeeded(config: Realm.Configuration) -> Error? {

        do {
            _ = try Realm(configuration: config)
        }
        catch let realmConfigError as NSError {

            if realmConfigError.code == Realm.Error.unsupportedFileFormatVersion.rawValue {
                
                do {
                    _ = try Realm.deleteFiles(for: config)
                }
                catch let deleteFilesError {
                    return deleteFilesError
                }
            }
            else {
                return realmConfigError
            }
        }

        return nil
    }

    func openRealm() -> Realm {
        
        return realmInstanceCreator.createRealm()
    }
    
    func background(async: @escaping ((_ realm: Realm) -> Void)) {
                
        realmInstanceCreator.createBackgroundRealm(async: async)
    }
}
