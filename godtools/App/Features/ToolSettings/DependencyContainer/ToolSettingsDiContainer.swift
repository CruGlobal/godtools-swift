//
//  ToolSettingsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolSettingsDiContainer {
    
    let dataLayer: ToolSettingsDataLayerDependencies
    let domainLayer: ToolSettingsDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = ToolSettingsDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = ToolSettingsDomainLayerDependencies(dataLayer: dataLayer)
    }
}
