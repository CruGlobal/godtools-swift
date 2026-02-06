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
    private let coreDomainlayer: AppDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: PersonalizedToolsDataLayerDependencies, coreDomainlayer: AppDomainLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
        self.coreDomainlayer = coreDomainlayer
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
            lessonProgressRepository: coreDataLayer.getUserLessonProgressRepository(),
            getLessonsListItems: coreDomainlayer.getLessonsListItems()
        )
    }
}
