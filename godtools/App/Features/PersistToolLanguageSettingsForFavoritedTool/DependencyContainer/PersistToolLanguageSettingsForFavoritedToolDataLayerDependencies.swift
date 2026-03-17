//
//  PersistToolLanguageSettingsForFavoritedToolDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class PersistToolLanguageSettingsForFavoritedToolDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
        
    func getUserToolSettingsRepository() -> UserToolSettingsRepository {
        return UserToolSettingsRepository(
            cache: RealmUserToolSettingsCache(realmDatabase: coreDataLayer.getSharedLegacyRealmDatabase())
        )
    }
}
