//
//  SpotlightToolsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class SpotlightToolsDiContainer {
    
    let dataLayer: SpotlightToolsDataLayerDependencies
    let domainLayer: SpotlightToolsDomainLayerDependencies
    
    init(dataLayer: SpotlightToolsDataLayerDependencies, domainLayer: SpotlightToolsDomainLayerDependencies) {

        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
