//
//  FeaturedLessonsDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class FeaturedLessonsDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    // MARK: - Domain Interface
    
    func getFeaturedLessonsRepositoryInterface() -> GetFeaturedLessonsRepositoryInterface {
        return GetFeaturedLessonsRepository(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            getTranslatedToolName: coreDataLayer.getTranslatedToolName(),
            getTranslatedToolLanguageAvailability: coreDataLayer.getTranslatedToolLanguageAvailability()
        )
    }
}
