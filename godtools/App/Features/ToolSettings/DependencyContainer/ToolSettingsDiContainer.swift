//
//  ToolSettingsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolSettingsDiContainer {
    
    private let dataLayer: ToolSettingsDataLayerDependencies
    
    let domainLayer: ToolSettingsDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies) {
        
        let dataLayer = ToolSettingsDataLayerDependencies(coreDataLayer: coreDataLayer)
        
        self.dataLayer = dataLayer
        domainLayer = ToolSettingsDomainLayerDependencies(coreDataLayer: coreDataLayer, coreDomainLayer: coreDomainLayer, dataLayer: dataLayer)
    }
}
