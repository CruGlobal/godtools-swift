//
//  PersistUserToolLanguageSettingsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 11/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class PersistUserToolLanguageSettingsDiContainer {
    
    let dataLayer: PersistUserToolLanguageSettingsDataLayerDependencies
    let domainLayer: PersistUserToolLanguageSettingsDomainLayerDependencies
    
    init(coreDataLayer: CoreDataLayerDependenciesInterface) {
        
        dataLayer = PersistUserToolLanguageSettingsDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = PersistUserToolLanguageSettingsDomainLayerDependencies(dataLayer: dataLayer)
    }
}
