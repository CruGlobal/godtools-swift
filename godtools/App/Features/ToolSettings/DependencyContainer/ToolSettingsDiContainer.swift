//
//  ToolSettingsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

@MainActor
final class ToolSettingsDiContainer {
    
    private let dataLayer: ToolSettingsDataLayerDependencies
    
    let domainLayer: ToolSettingsDomainLayerDependencies
    
    init(dataLayer: ToolSettingsDataLayerDependencies, domainLayer: ToolSettingsDomainLayerDependencies) {

        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
