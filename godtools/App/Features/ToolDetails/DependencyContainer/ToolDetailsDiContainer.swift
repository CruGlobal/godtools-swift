//
//  ToolDetailsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class ToolDetailsDiContainer {
    
    let dataLayer: ToolDetailsDataLayerDependencies
    let domainLayer: ToolDetailsDomainLayerDependencies
    
    init(dataLayer: ToolDetailsDataLayerDependencies, domainLayer: ToolDetailsDomainLayerDependencies) {

        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
