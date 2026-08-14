//
//  ShareablesDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class ShareablesDiContainer: Sendable {
    
    let dataLayer: ShareablesDataLayerDependencies
    let domainLayer: ShareablesDomainLayerDependencies
    
    init(dataLayer: ShareablesDataLayerDependencies, domainLayer: ShareablesDomainLayerDependencies) {

        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
