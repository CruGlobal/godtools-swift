//
//  ToolsFilterFeatureDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolsFilterFeatureDomainLayerDependencies {
    
    private let coreDomainLayer: AppDomainLayerDependencies
    private let dataLayer: ToolsFilterFeatureDataLayerDependencies
    
    init(coreDomainLayer: AppDomainLayerDependencies, dataLayer: ToolsFilterFeatureDataLayerDependencies) {
        
        self.coreDomainLayer = coreDomainLayer
        self.dataLayer = dataLayer
    }
    
    func getUserToolFiltersUseCase() -> GetUserToolFiltersUseCase {
        return GetUserToolFiltersUseCase(
            getUserToolFiltersRepositoryInterface: dataLayer.getUserToolFiltersRepositoryInterface()
        )
    }
    
    func getSearchToolFilterCategoriesUseCase() -> SearchToolFilterCategoriesUseCase {
        return SearchToolFilterCategoriesUseCase(
            searchToolFilterCategoriesRepository: dataLayer.getSearchToolFilterCategoriesRepositoryInterface()
        )
    }
    
    func getSearchToolFilterLanguagesUseCase() -> SearchToolFilterLanguagesUseCase {
        return SearchToolFilterLanguagesUseCase(
            searchToolFilterLanguagesRepository: dataLayer.getSearchToolFilterLanguagesRepositoryInterface()
        )
    }
    
    func getStoreUserToolFiltersUseCase() -> StoreUserToolFiltersUseCase {
        return StoreUserToolFiltersUseCase(
            storeUserToolFiltersRepositoryInterface: dataLayer.getStoreUserToolFiltersRepositoryInterface()
        )
    }
    
    func getViewToolFilterCategoriesUseCase() -> ViewToolFilterCategoriesUseCase {
        return ViewToolFilterCategoriesUseCase(
            getInterfaceStringsRepository: dataLayer.getToolFilterCategoriesInterfaceStringsRepositoryInterface(), 
            getToolFilterCategoriesRepository: dataLayer.getToolFilterCategoriesRepositoryInterface()
        )
    }
    
    func getViewToolFilterLanguagesUseCase() -> ViewToolFilterLanguagesUseCase {
        return ViewToolFilterLanguagesUseCase(
            getToolFilterLanguagesRepository: dataLayer.getToolFilterLanguagesRepositoryInterface(),
            getInterfaceStringsRepository: dataLayer.getToolFilterLanguagesInterfaceStringsRepositoryInterface()
        )
    }
}
