//
//  UserToolSettingsCache.swift
//  godtools
//
//  Created by Rachael Skeath on 5/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

final class UserToolSettingsCache {
    
    let persistence: any Persistence<UserToolSettingsDataModel, UserToolSettingsDataModel>
    
    init(persistence: any Persistence<UserToolSettingsDataModel, UserToolSettingsDataModel>) {
                
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    func getSwiftPersistence() -> SwiftRepositorySyncPersistence<UserToolSettingsDataModel, UserToolSettingsDataModel, SwiftUserToolSettings>? {
        return persistence as? SwiftRepositorySyncPersistence<UserToolSettingsDataModel, UserToolSettingsDataModel, SwiftUserToolSettings>
    }
    
    var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    func getRealmPersistence() -> RealmRepositorySyncPersistence<UserToolSettingsDataModel, UserToolSettingsDataModel, RealmUserToolSettings>? {
        return persistence as? RealmRepositorySyncPersistence<UserToolSettingsDataModel, UserToolSettingsDataModel, RealmUserToolSettings>
    }
}
