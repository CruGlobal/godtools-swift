//
//  ToolsFilterFeatureDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolsFilterFeatureDomainLayerDependencies {
    
    private let dataLayer: ToolsFilterFeatureDataLayerDependencies
    private let coreDataLayer: AppDataLayerDependencies // TODO: Eventually this needs to be removed as our UseCases in this feature will instead depend on interfaces. ~Levi
    private let coreDomainLayer: AppDomainLayerDependencies // TODO: Eventually this needs to be removed as our UseCases in this feature will not need to depend on UseCases. ~Levi
    
    init(dataLayer: ToolsFilterFeatureDataLayerDependencies, coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies) {
        
        self.dataLayer = dataLayer
        self.coreDataLayer = coreDataLayer
        self.coreDomainLayer = coreDomainLayer
    }
    
    func getUserFiltersUseCase() -> GetUserFiltersUseCase {
        return GetUserFiltersUseCase(
            getUserFiltersRepositoryInterface: dataLayer.getUserFiltersRepositoryInterface()
        )
    }
    
    func getSearchToolFilterCategoriesUseCase() -> SearchToolFilterCategoriesUseCase {
        return SearchToolFilterCategoriesUseCase(stringSearcher: StringSearcher())
    }
    
    func getSearchToolFilterLanguagesUseCase() -> SearchToolFilterLanguagesUseCase {
        return SearchToolFilterLanguagesUseCase(stringSearcher: StringSearcher())
    }
    
    func getStoreUserFiltersUseCase() -> StoreUserFiltersUseCase {
        return StoreUserFiltersUseCase(
            storeUserFiltersRepositoryInterface: dataLayer.getStoreUserFiltersRepositoryInterface()
        )
    }
    
    func getViewToolFilterCategoriesUseCase() -> ViewToolFilterCategoriesUseCase {
        return ViewToolFilterCategoriesUseCase(
            getToolFilterCategoriesRepository: dataLayer.getToolFilterCategoriesRepositoryInterface()
        )
    }
    
    func getViewToolFilterLanguagesUseCase() -> ViewToolFilterLanguagesUseCase {
        return ViewToolFilterLanguagesUseCase(
            getToolFilterLanguagesRepository: dataLayer.getToolFilterLanguagesRepositoryInterface()
        )
    }
}
