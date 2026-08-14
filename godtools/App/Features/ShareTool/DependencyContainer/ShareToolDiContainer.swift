//
//  ShareToolDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/8/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class ShareToolDiContainer: Sendable {
        
    private let dataLayer: ShareToolDataLayerDependencies
    
    let domainLayer: ShareToolDomainLayerDependencies
    
    init(dataLayer: ShareToolDataLayerDependencies, domainLayer: ShareToolDomainLayerDependencies) {

        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
