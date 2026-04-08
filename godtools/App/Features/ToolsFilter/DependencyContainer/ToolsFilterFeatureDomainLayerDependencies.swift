//
//  ToolsFilterFeatureDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolsFilterFeatureDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let coreDomainLayer: AppDomainLayerDependencies
    private let dataLayer: ToolsFilterFeatureDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies, dataLayer: ToolsFilterFeatureDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.coreDomainLayer = coreDomainLayer
        self.dataLayer = dataLayer
    }
    
    func getToolFilterCategoriesStringsUseCase() -> GetToolFilterCategoriesStringsUseCase {
        return GetToolFilterCategoriesStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getToolFilterCategoriesUseCase() -> GetToolFilterCategoriesUseCase {
        return GetToolFilterCategoriesUseCase(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            getToolFilterCategory: getToolFilterCategory()
        )
    }
    
    func getToolFilterLanguagesStringsUseCase() -> GetToolFilterLanguagesStringsUseCase {
        return GetToolFilterLanguagesStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getToolFilterLanguagesUseCase() -> GetToolFilterLanguagesUseCase {
        return GetToolFilterLanguagesUseCase(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            getToolFilterLanguage: getToolFilterLanguage()
        )
    }
    
    func getUserToolFilterCategoryUseCase() -> GetUserToolFilterCategoryUseCase {
        return GetUserToolFilterCategoryUseCase(
            userToolFiltersRepository: dataLayer.getUserToolFiltersRepository(),
            getToolFilterCategory: getToolFilterCategory()
        )
    }
    
    func getUserToolFilterLanguageUseCase() -> GetUserToolFilterLanguageUseCase {
        return GetUserToolFilterLanguageUseCase(
            userToolFiltersRepository: dataLayer.getUserToolFiltersRepository(),
            getToolFilterLanguage: getToolFilterLanguage()
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
}

// MARK: - Supporting

extension ToolsFilterFeatureDomainLayerDependencies {
    
    private func getToolFilterCategory() -> GetToolFilterCategory {
        return GetToolFilterCategory(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            localizationServices: coreDataLayer.getLocalizationServices(),
            stringWithLocaleCount: coreDataLayer.getStringWithLocaleCount()
        )
    }
    
    private func getToolFilterLanguage() -> GetToolFilterLanguage {
        return GetToolFilterLanguage(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: coreDomainLayer.supporting.getTranslatedLanguageName(),
            localizationServices: coreDataLayer.getLocalizationServices(),
            stringWithLocaleCount: coreDataLayer.getStringWithLocaleCount()
        )
    }
}
