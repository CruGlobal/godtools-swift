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
        
    func getUserToolFiltersRepository() -> UserToolFiltersRepository {
        return UserToolFiltersRepository(
            cache: RealmUserToolFiltersCache(
                realmDatabase: coreDataLayer.getSharedLegacyRealmDatabase()
            )
        )
    }
        
    func getSearchToolFilterCategoriesRepositoryInterface() -> SearchToolFilterCategoriesRepositoryInterface {
        return SearchToolFilterCategoriesRepository(
            stringSearcher: StringSearcher()
        )
    }
    
    func getSearchToolFilterLanguagesRepositoryInterface() -> SearchToolFilterLanguagesRepositoryInterface {
        return SearchToolFilterLanguagesRepository(
            stringSearcher: StringSearcher()
        )
    }
    
    func getStoreUserToolFiltersRepositoryInterface() -> StoreUserToolFiltersRepositoryInterface {
        return StoreUserToolFiltersRepository(userToolFiltersRepository: getUserToolFiltersRepository())
    }
}
