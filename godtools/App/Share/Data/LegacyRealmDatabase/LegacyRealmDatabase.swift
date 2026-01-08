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
    
    private let config: Realm.Configuration
    private let realmInstanceCreator: RealmInstanceCreator
    
    init(config: Realm.Configuration, realmInstanceCreationType: RealmInstanceCreationType = .alwaysCreatesANewRealmInstance) {
        
        self.config = config
        self.realmInstanceCreator = RealmInstanceCreator(config: config, creationType: realmInstanceCreationType)
        
        _ = checkForUnsupportedFileFormatVersionAndDeleteRealmFilesIfNeeded(config: config)
    }
    
    convenience init(databaseConfiguration: RealmDatabaseConfiguration, realmInstanceCreationType: RealmInstanceCreationType = .alwaysCreatesANewRealmInstance) {
        
        self.init(config: databaseConfiguration.getRealmConfig(), realmInstanceCreationType: realmInstanceCreationType)
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
