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
        
        return GetLocalizationSettingsCountryListUseCase()
    }
    
    func getViewLocalizationSettingsUseCase() -> ViewLocalizationSettingsUseCase {
        
        return ViewLocalizationSettingsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
}
