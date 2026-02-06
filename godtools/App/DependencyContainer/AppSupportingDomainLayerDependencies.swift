//
//  AppSupportingDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class AppSupportingDomainLayerDependencies {
    
    private let dataLayer: AppDataLayerDependencies
    
    init(dataLayer: AppDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getLessonsListItems() -> GetLessonsListItems {
        return GetLessonsListItems(
            languagesRepository: dataLayer.getLanguagesRepository(),
            getTranslatedToolName: dataLayer.getTranslatedToolName(),
            getTranslatedToolLanguageAvailability: dataLayer.getTranslatedToolLanguageAvailability(),
            getLessonListItemProgressRepository: dataLayer.getLessonListItemProgressRepository()
        )
    }
    
    func getToolsListItems() -> GetToolsListItems {
        return GetToolsListItems(
            favoritedResourcesRepository: dataLayer.getFavoritedResourcesRepository(),
            languagesRepository: dataLayer.getLanguagesRepository(),
            getTranslatedToolName: dataLayer.getTranslatedToolName(),
            getTranslatedToolCategory: dataLayer.getTranslatedToolCategory(),
            getToolListItemInterfaceStringsRepository: dataLayer.getToolListItemInterfaceStringsRepository(),
            getTranslatedToolLanguageAvailability: dataLayer.getTranslatedToolLanguageAvailability()
        )
    }
}
