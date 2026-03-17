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
    
    func getLanguageElseAppLanguage() -> GetLanguageElseAppLanguage {
        return GetLanguageElseAppLanguage(
            languagesRepository: dataLayer.getLanguagesRepository()
        )
    }
    
    func getLessonListItemProgress() -> GetLessonListItemProgress {
        return GetLessonListItemProgress(
            lessonProgressRepository: dataLayer.getUserLessonProgressRepository(),
            userCountersRepository: dataLayer.getUserCountersRepository(),
            localizationServices: dataLayer.getLocalizationServices(),
            getTranslatedPercentage: getTranslatedPercentage()
        )
    }
    
    func getLessonsListItems() -> GetLessonsListItems {
        return GetLessonsListItems(
            languagesRepository: dataLayer.getLanguagesRepository(),
            getTranslatedToolName: getTranslatedToolName(),
            getTranslatedToolLanguageAvailability: getTranslatedToolLanguageAvailability(),
            getLessonListItemProgress: getLessonListItemProgress()
        )
    }
    
    func getLocalizationLanguageName() -> LocalizationLanguageName {
        return LocalizationLanguageName(
            localizationServices: dataLayer.getLocalizationServices()
        )
    }
    
    func getSearchBarStrings() -> GetSearchBarStrings {
        return GetSearchBarStrings(
            localizationServices: dataLayer.getLocalizationServices()
        )
    }
    
    func getToolsListItems() -> GetToolsListItems {
        return GetToolsListItems(
            favoritedResourcesRepository: dataLayer.getFavoritedResourcesRepository(),
            languagesRepository: dataLayer.getLanguagesRepository(),
            getTranslatedToolName: getTranslatedToolName(),
            getTranslatedToolCategory: getTranslatedToolCategory(),
            getToolListItemStrings: getToolListItemStrings(),
            getTranslatedToolLanguageAvailability: getTranslatedToolLanguageAvailability()
        )
    }
    
    func getToolListItemStrings() -> GetToolListItemStrings {
        return GetToolListItemStrings(
            localizationServices: dataLayer.getLocalizationServices()
        )
    }
    
    func getTranslatedLanguageName() -> GetTranslatedLanguageName {
        return GetTranslatedLanguageName(
            localizationLanguageName: getLocalizationLanguageName(),
            localeLanguageName: LocaleLanguageName(),
            localeRegionName: LocaleLanguageRegionName(),
            localeScriptName: LocaleLanguageScriptName()
        )
    }
    
    func getTranslatedNumberCount() -> GetTranslatedNumberCount {
        return GetTranslatedNumberCount()
    }
    
    func getTranslatedPercentage() -> GetTranslatedPercentage {
        return GetTranslatedPercentage()
    }
    
    func getTranslatedToolCategory() -> GetTranslatedToolCategory {
        return GetTranslatedToolCategory(
            localizationServices: dataLayer.getLocalizationServices(),
            resourcesRepository: dataLayer.getResourcesRepository()
        )
    }
    
    func getTranslatedToolLanguageAvailability() -> GetTranslatedToolLanguageAvailability {
        return GetTranslatedToolLanguageAvailability(
            localizationServices: dataLayer.getLocalizationServices(),
            resourcesRepository: dataLayer.getResourcesRepository(),
            languagesRepository: dataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: getTranslatedLanguageName()
        )
    }
    
    func getTranslatedToolName() -> GetTranslatedToolName {
        return GetTranslatedToolName(
            resourcesRepository: dataLayer.getResourcesRepository(),
            translationsRepository: dataLayer.getTranslationsRepository()
        )
    }
}
