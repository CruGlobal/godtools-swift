//
//  PersonalizedToolsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class PersonalizedToolsDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: PersonalizedToolsDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: PersonalizedToolsDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }
    
    func getLocalizationSettingsCountryListUseCase() -> GetLocalizationSettingsCountryListUseCase {
        
        return GetLocalizationSettingsCountryListUseCase(
            countriesRepository: dataLayer.getLocalizationSettingsCountriesRepository())
    }
    
    func getSearchCountriesInLocalizationSettingsCountriesListUseCase() -> SearchCountriesInLocalizationSettingsCountriesListUseCase {
        
        return SearchCountriesInLocalizationSettingsCountriesListUseCase(
            stringSearcher: StringSearcher()
        )
    }
    
    func getViewLocalizationSettingsUseCase() -> ViewLocalizationSettingsUseCase {

        return ViewLocalizationSettingsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
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
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            personalizedLessonsRepository: dataLayer.getPersonalizedLessonsRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            getTranslatedToolName: coreDataLayer.getTranslatedToolName(),
            getTranslatedToolLanguageAvailability: coreDataLayer.getTranslatedToolLanguageAvailability(),
            lessonProgressRepository: coreDataLayer.getUserLessonProgressRepository(),
            getLessonListItemProgressRepository: coreDataLayer.getLessonListItemProgressRepository()
        )
    }
}
