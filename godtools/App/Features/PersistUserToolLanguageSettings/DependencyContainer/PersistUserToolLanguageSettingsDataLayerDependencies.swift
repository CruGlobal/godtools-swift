//
//  PersistUserToolLanguageSettingsDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class PersistUserToolLanguageSettingsDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    func getUserToolSettingsRepository() -> UserToolSettingsRepository {
        return UserToolSettingsRepository(
            cache: RealmUserToolSettingsCache(realmDatabase: coreDataLayer.getSharedRealmDatabase())
        )
    }
    
    // MARK: - Domain Interface
    
    func getPersistUserToolLanguageSettingsRepositoryInterface() -> PersistUserToolLanguageSettingsRepositoryInterface {
        return PersistUserToolLanguageSettingsRepository(
            userToolSettingsRepository: getUserToolSettingsRepository()
        )
    }
}
