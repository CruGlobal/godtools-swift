//
//  ShareablesDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

@MainActor
final class ShareablesDiContainer {
    
    let dataLayer: ShareablesDataLayerDependencies
    let domainLayer: ShareablesDomainLayerDependencies
    
    init(dataLayer: ShareablesDataLayerDependencies, domainLayer: ShareablesDomainLayerDependencies) {

        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
