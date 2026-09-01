//
//  PersonalizedToolsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class PersonalizedToolsDomainLayerDependencies: Sendable {
    
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

    func getLocalizationSettingsConfirmationStringsUseCase() -> GetLocalizationSettingsConfirmationStringsUseCase {

        return GetLocalizationSettingsConfirmationStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getLocalizationSettingsStringsUseCase() -> GetLocalizationSettingsStringsUseCase {

        return GetLocalizationSettingsStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getLocalizationSettingsUseCase() -> GetLocalizationSettingsUseCase {

        return GetLocalizationSettingsUseCase(
            userLocalizationSettingsRepository: dataLayer.getUserLocalizationSettingsRepository()
        )
    }
    
    func getPersonalizedLessonFilterLanguagesStringsUseCase() -> GetPersonalizedLessonFilterLanguagesStringsUseCase {

        return GetPersonalizedLessonFilterLanguagesStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }

    func getPersonalizedLessonFilterLanguagesUseCase() -> GetPersonalizedLessonFilterLanguagesUseCase {

        return GetPersonalizedLessonFilterLanguagesUseCase(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            languagesRepository: core.dataLayer.getLanguagesRepository()
        )
    }

    func getUserPersonalizedLessonFilterLanguageUseCase() -> GetUserPersonalizedLessonFilterLanguageUseCase {

        return GetUserPersonalizedLessonFilterLanguageUseCase()
    }

    func getSearchPersonalizedLessonFilterLanguagesUseCase() -> SearchPersonalizedLessonFilterLanguagesUseCase {

        return SearchPersonalizedLessonFilterLanguagesUseCase(
            stringSearcher: StringSearcher()
        )
    }

    func getSetUserPersonalizedLessonFilterLanguageUseCase() -> SetUserPersonalizedLessonFilterLanguageUseCase {

        return SetUserPersonalizedLessonFilterLanguageUseCase()
    }

    func getSearchCountriesInLocalizationSettingsCountriesListUseCase() -> SearchCountriesInLocalizationSettingsCountriesListUseCase {
        
        return SearchCountriesInLocalizationSettingsCountriesListUseCase(
            stringSearcher: StringSearcher()
        )
    }

    func getSetLocalizationSettingsUseCase() -> SetLocalizationSettingsUseCase {

        return SetLocalizationSettingsUseCase(
            userLocalizationSettingsRepository: dataLayer.getUserLocalizationSettingsRepository()
        )
    }

    func getPersonalizedLessonsUseCase() -> GetPersonalizedLessonsUseCase {

        return GetPersonalizedLessonsUseCase(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            personalizedToolsRepository: dataLayer.getPersonalizedToolsRepository(),
            getLanguageElseAppLanguage: core.domainLayer.supporting.getLanguageElseAppLanguage(),
            lessonProgressRepository: core.dataLayer.getUserLessonProgressRepository(),
            getLessonsListItems: core.domainLayer.supporting.getLessonsListItems(),
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }

    func getPersonalizedToolsUseCase() -> GetPersonalizedToolsUseCase {

        return GetPersonalizedToolsUseCase(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            personalizedToolsRepository: dataLayer.getPersonalizedToolsRepository(),
            getLanguageElseAppLanguage: core.domainLayer.supporting.getLanguageElseAppLanguage(),
            getToolsListItems: core.domainLayer.supporting.getToolsListItems(),
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
}
