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
    
    func getToolFilterCategoriesUseCase() -> GetToolFilterCategoriesUseCase {
        return GetToolFilterCategoriesUseCase(
            getAllToolsUseCase: coreDomainLayer.getAllToolsUseCase(),
            getSettingsPrimaryLanguageUseCase: coreDomainLayer.getSettingsPrimaryLanguageUseCase(),
            localizationServices: coreDataLayer.getLocalizationServices(),
            resourcesRepository: coreDataLayer.getResourcesRepository()
        )
    }
    
    func getToolFilterLanguagesUseCase() -> GetToolFilterLanguagesUseCase {
        return GetToolFilterLanguagesUseCase(
            getAllToolsUseCase: coreDomainLayer.getAllToolsUseCase(),
            getLanguageUseCase: coreDomainLayer.getLanguageUseCase(),
            getSettingsPrimaryLanguageUseCase: coreDomainLayer.getSettingsPrimaryLanguageUseCase(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            localeLanguageName: coreDataLayer.getLocaleLanguageName(),
            localizationServices: coreDataLayer.getLocalizationServices()
        )
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
}
