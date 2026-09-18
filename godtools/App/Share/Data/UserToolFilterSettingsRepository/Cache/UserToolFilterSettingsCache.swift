//
//  UserToolFilterSettingsCache.swift
//  godtools
//
//  Created by Rachael Skeath on 9/17/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftData
import RepositorySync

final class UserToolFilterSettingsCache: Sendable {
    
    let persistence: any Persistence<UserToolFilterSettingsDataModel, UserToolFilterSettingsDataModel>
    
    init(persistence: any Persistence<UserToolFilterSettingsDataModel, UserToolFilterSettingsDataModel>) {
        
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<UserToolFilterSettingsDataModel, UserToolFilterSettingsDataModel, SwiftUserToolFilterSettings>? {
        return persistence as? SwiftRepositorySyncPersistence<UserToolFilterSettingsDataModel, UserToolFilterSettingsDataModel, SwiftUserToolFilterSettings>
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<UserToolFilterSettingsDataModel, UserToolFilterSettingsDataModel, RealmUserToolFilterSettings>? {
        return persistence as? RealmRepositorySyncPersistence<UserToolFilterSettingsDataModel, UserToolFilterSettingsDataModel, RealmUserToolFilterSettings>
    }
}
