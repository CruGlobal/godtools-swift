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
    private let personalizedToolsDataLayer: PersonalizedToolsDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: LessonsFeatureDataLayerDependencies, coreDomainlayer: AppDomainLayerDependencies, personalizedToolsDataLayer: PersonalizedToolsDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
        self.coreDomainlayer = coreDomainlayer
        self.personalizedToolsDataLayer = personalizedToolsDataLayer
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
    
    func getPullToRefreshLessonsUseCase() -> PullToRefreshLessonsUseCase {
        return PullToRefreshLessonsUseCase(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            personalizedLessonsRepository: personalizedToolsDataLayer.getPersonalizedLessonsRepository(),
            getLanguageElseAppLanguage: coreDomainlayer.supporting.getLanguageElseAppLanguage()
        )
    }
}
