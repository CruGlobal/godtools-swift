//
//  ToolSettingsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class ToolSettingsDiContainer {
    
    private let dataLayer: ToolSettingsDataLayerDependencies
    
    let domainLayer: ToolSettingsDomainLayerDependencies
    
    init(core: AppCoreDiContainer) {
        
        let dataLayer = ToolSettingsDataLayerDependencies(coreDataLayer: core.dataLayer)
        
        self.dataLayer = dataLayer
        domainLayer = ToolSettingsDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
