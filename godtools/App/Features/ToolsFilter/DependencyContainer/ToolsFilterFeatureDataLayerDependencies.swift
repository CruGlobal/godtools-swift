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
    
    func getUserToolFiltersRepository() -> UserToolFiltersRepository {
        return UserToolFiltersRepository(
            cache: RealmUserToolFiltersCache(
                realmDatabase: coreDataLayer.getSharedRealmDatabase()
            )
        )
    }
    
    func getToolFilterCategoriesRepository() -> GetToolFilterCategoriesRepository {
        return GetToolFilterCategoriesRepository(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getToolFilterCategoriesInterfaceStringsRepository() -> GetToolFilterCategoriesInterfaceStringsRepository {
        return GetToolFilterCategoriesInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getToolFilterLanguagesRepository() -> GetToolFilterLanguagesRepository {
        return GetToolFilterLanguagesRepository(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            translatedLanguageNameRepository: coreDataLayer.getTranslatedLanguageNameRepository(),
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getToolFilterLanguagesInterfaceStringsRepository() -> GetToolFilterLanguagesInterfaceStringsRepository {
        return GetToolFilterLanguagesInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    // MARK: - Domain Interface
    
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
    
    func getToolFilterCategoriesRepositoryInterface() -> GetToolFilterCategoriesRepositoryInterface {
        return getToolFilterCategoriesRepository()
    }
    
    func getToolFilterCategoriesInterfaceStringsRepositoryInterface() ->  GetToolFilterCategoriesInterfaceStringsRepositoryInterface {
        return getToolFilterCategoriesInterfaceStringsRepository()
    }
    
    func getToolFilterLanguagesRepositoryInterface() -> GetToolFilterLanguagesRepositoryInterface {
        return getToolFilterLanguagesRepository()
    }
    
    func getToolFilterLanguagesInterfaceStringsRepositoryInterface() ->  GetToolFilterLanguagesInterfaceStringsRepositoryInterface {
        return getToolFilterLanguagesInterfaceStringsRepository()
    }
    
    func getUserToolFiltersRepositoryInterface() -> GetUserToolFiltersRepositoryInterface {
        return GetUserToolFiltersRepository(
            userToolFiltersRepository: getUserToolFiltersRepository(),
            getToolFilterCategoriesRepository: getToolFilterCategoriesRepository(),
            getToolFilterLanguagesRepository: getToolFilterLanguagesRepository()
        )
    }
}
