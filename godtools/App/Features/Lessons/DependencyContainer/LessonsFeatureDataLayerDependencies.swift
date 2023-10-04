//
//  LessonsFeatureDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class LessonsFeatureDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    // MARK: - Domain Interface
    
    func getLessonIsAvailableInAppLanguageRepositoryInterface() -> GetLessonIsAvailableInAppLanguageRepositoryInterface {
        return GetLessonIsAvailableInAppLanguageRepository(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository()
        )
    }
    
    func getLessonNameRepositoryInterface() -> GetLessonNameRepositoryInterface {
        return GetLessonNameRepository(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            translationsRepository: coreDataLayer.getTranslationsRepository()
        )
    }
    
    func getLessonsListRepositoryInterface() -> GetLessonsListRepositoryInterface {
        return GetLessonsListRepository(
            resourcesRepository: coreDataLayer.getResourcesRepository()
        )
    }
}
