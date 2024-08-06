//
//  LessonFilterDataLayerDependencies.swift
//  godtools
//
//  Created by Rachael Skeath on 7/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class LessonFilterDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes

    func getLessonFilterLanguagesRepository() -> GetLessonFilterLanguagesRepository {
        return GetLessonFilterLanguagesRepository(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: coreDataLayer.getTranslatedLanguageName(),
            localizationServices: coreDataLayer.getLocalizationServices(),
            stringWithLocaleCount: coreDataLayer.getStringWithLocaleCount()
        )
    }
        
    // MARK: - Domain Interface
    
    func getLessonFilterLanguagesInterfaceStringsRepositoryInterface() -> GetLessonFilterLanguagesInterfaceStringsRepositoryInterface {
        
        return GetLessonFilterLanguagesInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getLessonFilterLanguagesRepositoryInterface() -> GetLessonFilterLanguagesRepositoryInterface {
        
        return getLessonFilterLanguagesRepository()
    }
    
    func getSearchLessonFilterLanguagesRepositoryInterface() -> SearchLessonFilterLanguagesRepositoryInterface {
        return SearchLessonFilterLanguagesRepository(stringSearcher: StringSearcher())
    }
    
    func getStoreUserLessonFiltersRepositoryInterface() -> StoreUserLessonFiltersRepositoryInterface {
        return StoreUserLessonFiltersRepository(userLessonFiltersRepository: coreDataLayer.getUserLessonFiltersRepository())
    }
    
    func getUserLessonFiltersRepositoryInterface() -> GetUserLessonFiltersRepositoryInterface {
        return GetUserLessonFiltersRepository(
            userLessonFiltersRepository: coreDataLayer.getUserLessonFiltersRepository(),
            getLessonFilterLanguagesRepository: getLessonFilterLanguagesRepository()
        )
    }
}
