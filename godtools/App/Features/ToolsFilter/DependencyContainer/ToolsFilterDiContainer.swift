//
//  ToolsFilterDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 11/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class ToolsFilterDiContainer: Sendable {
    
    let dataLayer: ToolsFilterDataLayerDependencies
    let domainLayer: ToolsFilterDomainLayerDependencies
    
    init(dataLayer: ToolsFilterDataLayerDependencies, domainLayer: ToolsFilterDomainLayerDependencies) {

        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
