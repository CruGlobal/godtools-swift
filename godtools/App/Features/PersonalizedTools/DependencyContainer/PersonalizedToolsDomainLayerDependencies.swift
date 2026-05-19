//
//  PersonalizedToolsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class PersonalizedToolsDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: PersonalizedToolsDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: PersonalizedToolsDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getLocalizationSettingsCountryListUseCase() -> GetLocalizationSettingsCountryListUseCase {

        return GetLocalizationSettingsCountryListUseCase(
            countriesRepository: dataLayer.getLocalizationSettingsCountriesRepository(),
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getSearchCountriesInLocalizationSettingsCountriesListUseCase() -> SearchCountriesInLocalizationSettingsCountriesListUseCase {
        
        return SearchCountriesInLocalizationSettingsCountriesListUseCase(
            stringSearcher: StringSearcher()
        )
    }
    
    func getViewLocalizationSettingsUseCase() -> ViewLocalizationSettingsUseCase {

        return ViewLocalizationSettingsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }

    func getLocalizationSettingsConfirmationStringsUseCase() -> GetLocalizationSettingsConfirmationStringsUseCase {

        return GetLocalizationSettingsConfirmationStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getGetLocalizationSettingsUseCase() -> GetLocalizationSettingsUseCase {

        return GetLocalizationSettingsUseCase(
            userLocalizationSettingsRepository: dataLayer.getUserLocalizationSettingsRepository()
        )
    }

    func getSetLocalizationSettingsUseCase() -> SetLocalizationSettingsUseCase {

        return SetLocalizationSettingsUseCase(
            userLocalizationSettingsRepository: dataLayer.getUserLocalizationSettingsRepository()
        )
    }

    func getGetPersonalizedLessonsUseCase() -> GetPersonalizedLessonsUseCase {

        return GetPersonalizedLessonsUseCase(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            personalizedToolsRepository: dataLayer.getPersonalizedToolsRepository(),
            getLanguageElseAppLanguage: core.domainLayer.supporting.getLanguageElseAppLanguage(),
            lessonProgressRepository: core.dataLayer.getUserLessonProgressRepository(),
            getLessonsListItems: core.domainLayer.supporting.getLessonsListItems(),
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }

    func getGetPersonalizedToolsUseCase() -> GetPersonalizedToolsUseCase {

        return GetPersonalizedToolsUseCase(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            personalizedToolsRepository: dataLayer.getPersonalizedToolsRepository(),
            getLanguageElseAppLanguage: core.domainLayer.supporting.getLanguageElseAppLanguage(),
            getToolsListItems: core.domainLayer.supporting.getToolsListItems(),
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
}
