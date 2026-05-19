//
//  LessonsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class LessonsDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: LessonsDataLayerDependencies
    private let personalizedToolsDataLayer: PersonalizedToolsDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: LessonsDataLayerDependencies, personalizedToolsDataLayer: PersonalizedToolsDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
        self.personalizedToolsDataLayer = personalizedToolsDataLayer
    }
    
    func getAllLessonsUseCase() -> GetAllLessonsUseCase {
        return GetAllLessonsUseCase(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            lessonProgressRepository: core.dataLayer.getUserLessonProgressRepository(),
            getLessonsListItems: core.domainLayer.supporting.getLessonsListItems()
        )
    }
    
    func getLessonsStringsUseCase() -> GetLessonsStringsUseCase {
        return GetLessonsStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getPullToRefreshLessonsUseCase() -> PullToRefreshLessonsUseCase {
        return PullToRefreshLessonsUseCase(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            personalizedToolsRepository: personalizedToolsDataLayer.getPersonalizedToolsRepository(),
            getLanguageElseAppLanguage: core.domainLayer.supporting.getLanguageElseAppLanguage()
        )
    }
}
