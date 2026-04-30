//
//  ToolsFilterFeatureDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class ToolsFilterFeatureDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
        
    func getUserToolFiltersRepository() -> UserToolFiltersRepository {
        
        let categoryPersistence: any Persistence<UserToolCategoryFilterDataModel, UserToolCategoryFilterDataModel>
        let languagePersistence: any Persistence<UserToolLanguageFilterDataModel, UserToolLanguageFilterDataModel>
        
        if #available(iOS 17.4, *), let database = coreDataLayer.getSharedSwiftDatabase() {
            
            categoryPersistence = SwiftRepositorySyncPersistence(
                database: database,
                dataModelMapping: SwiftUserToolCategoryFilterMapping()
            )
            
            languagePersistence = SwiftRepositorySyncPersistence(
                database: database,
                dataModelMapping: SwiftUserToolLanguageFilterMapping()
            )
        }
        else {
            
            categoryPersistence = RealmRepositorySyncPersistence(
                database: coreDataLayer.getSharedRealmDatabase(),
                dataModelMapping: RealmUserToolCategoryFilterMapping()
            )
            
            languagePersistence = RealmRepositorySyncPersistence(
                database: coreDataLayer.getSharedRealmDatabase(),
                dataModelMapping: RealmUserToolLanguageFilterMapping()
            )
        }
        
        return UserToolFiltersRepository(
            cache: UserToolFiltersCache(
                categoryPersistence: categoryPersistence,
                languagePersistence: languagePersistence
            )
        )
    }
}
