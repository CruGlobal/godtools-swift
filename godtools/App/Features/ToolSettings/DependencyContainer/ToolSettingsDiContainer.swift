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
    private let domainInterfaceLayer: ToolSettingsDomainInterfaceDependencies
    
    let domainLayer: ToolSettingsDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies) {
        
        let dataLayer = ToolSettingsDataLayerDependencies(coreDataLayer: coreDataLayer)
        
        self.dataLayer = dataLayer
        domainInterfaceLayer = ToolSettingsDomainInterfaceDependencies(coreDataLayer: coreDataLayer, coreDomainLayer: coreDomainLayer, dataLayer: dataLayer)
        domainLayer = ToolSettingsDomainLayerDependencies(domainInterfaceLayer: domainInterfaceLayer)
    }
}
