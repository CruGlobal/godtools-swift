//
//  UserLocalizationSettingsCache.swift
//  godtools
//
//  Created by Rachael Skeath on 1/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import RealmSwift

final class UserLocalizationSettingsCache {
        
    let persistence: any Persistence<UserLocalizationSettingsDataModel, UserLocalizationSettingsDataModel>
    
    init(persistence: any Persistence<UserLocalizationSettingsDataModel, UserLocalizationSettingsDataModel>) {
                
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<UserLocalizationSettingsDataModel, UserLocalizationSettingsDataModel, SwiftUserLocalizationSettings>? {
        return persistence as? SwiftRepositorySyncPersistence<UserLocalizationSettingsDataModel, UserLocalizationSettingsDataModel, SwiftUserLocalizationSettings>
    }
    
    private var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<UserLocalizationSettingsDataModel, UserLocalizationSettingsDataModel, RealmUserLocalizationSettings>? {
        return persistence as? RealmRepositorySyncPersistence<UserLocalizationSettingsDataModel, UserLocalizationSettingsDataModel, RealmUserLocalizationSettings>
    }
}

extension UserLocalizationSettingsCache {

    func storeUserLocalizationSetting(dataModel: UserLocalizationSettingsDataModel) async throws {
        
        _ = try await persistence
            .writeObjectsAsync(
                externalObjects: [dataModel],
                writeOption: nil,
                getOption: nil
            )
    }
}
