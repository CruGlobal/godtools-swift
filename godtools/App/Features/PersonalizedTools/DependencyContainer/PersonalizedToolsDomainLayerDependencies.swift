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
    
    func getPersonalizedToolToggleInterfaceStringsUseCase() -> GetPersonalizedToolToggleInterfaceStringsUseCase {
        
        return GetPersonalizedToolToggleInterfaceStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
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
}
