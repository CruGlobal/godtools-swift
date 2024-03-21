//
//  ToolsFilterFeatureDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolsFilterFeatureDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    func getUserFiltersRepository() -> UserFiltersRepository {
        return UserFiltersRepository(
            cache: UserFiltersUserDefaultsCache(
                sharedUserDefaultsCache: coreDataLayer.getSharedUserDefaultsCache()
            )
        )
    }
    
    // MARK: - Domain Interface
    
    func getStoreUserFiltersRepositoryInterface() -> StoreUserFiltersRepositoryInterface {
        return StoreUserFiltersRepository(userFiltersRepository: getUserFiltersRepository())
    }
    
    func getUserFiltersRepositoryInterface() -> GetUserFiltersRepositoryInterface {
        return GetUserFiltersRepository(
            userFiltersRepository: getUserFiltersRepository()
        )
    }
}
