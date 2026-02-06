//
//  LessonsFeatureDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class LessonsFeatureDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: LessonsFeatureDataLayerDependencies
    private let coreDomainlayer: AppDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: LessonsFeatureDataLayerDependencies, coreDomainlayer: AppDomainLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
        self.coreDomainlayer = coreDomainlayer
    }
    
    func getAllLessonsUseCase() -> GetAllLessonsUseCase {
        return GetAllLessonsUseCase(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            lessonProgressRepository: coreDataLayer.getUserLessonProgressRepository(),
            getLessonsListItems: coreDomainlayer.supporting.getLessonsListItems()
        )
    }
    
    func getLessonsStringsUseCase() -> GetLessonsStringsUseCase {
        return GetLessonsStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
}
