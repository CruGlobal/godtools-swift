//
//  PersistToolLanguageSettingsForFavoritedToolDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RepositorySync

class PersistToolLanguageSettingsForFavoritedToolDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
        
    func getUserToolSettingsRepository() -> UserToolSettingsRepository {
        
        let persistence: any Persistence<UserToolSettingsDataModel, UserToolSettingsDataModel>
        
        if #available(iOS 17.4, *), let database = coreDataLayer.getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                dataModelMapping: SwiftUserToolSettingsMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                database: coreDataLayer.getSharedRealmDatabase(),
                dataModelMapping: RealmUserToolSettingsMapping()
            )
        }
        
        return UserToolSettingsRepository(
            cache: UserToolSettingsCache(
                persistence: persistence
            )
        )
    }
}
