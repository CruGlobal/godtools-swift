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
    
    // MARK: - Domain Interface
    
    func getLessonFilterLanguagesInterfaceStringsRepositoryInterface() -> GetLessonFilterLanguagesInterfaceStringsRepositoryInterface {
        
        return GetLessonFilterLanguagesInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getLessonFilterLanguagesRepositoryInterface() -> GetLessonFilterLanguagesRepositoryInterface {
        
        return GetLessonFilterLanguagesRepository(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            translatedLanguageNameRepository: coreDataLayer.getTranslatedLanguageNameRepository(),
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getSearchLessonFilterLanguagesRepositoryInterface() -> SearchLessonFilterLanguagesRepositoryInterface {
        return SearchLessonFilterLanguagesRepository(stringSearcher: StringSearcher())
    }
}
