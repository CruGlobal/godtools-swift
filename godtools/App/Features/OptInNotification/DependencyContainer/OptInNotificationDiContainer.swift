//
//  OptInNotificationDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

@MainActor
final class OptInNotificationDiContainer {
        
    let dataLayer: OptInNotificationDataLayerDependencies
    let domainLayer: OptInNotificationDomainLayerDependencies
    
    init(dataLayer: OptInNotificationDataLayerDependencies, domainLayer: OptInNotificationDomainLayerDependencies) {
        
        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
