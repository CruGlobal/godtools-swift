//
//  MenuDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 8/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class MenuDiContainer: Sendable {
    
    let dataLayer: MenuDataLayerDependencies
    let domainLayer: MenuDomainLayerDependencies
    
    init(dataLayer: MenuDataLayerDependencies, domainLayer: MenuDomainLayerDependencies) {

        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
