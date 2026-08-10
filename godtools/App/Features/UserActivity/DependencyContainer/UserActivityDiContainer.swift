//
//  UserActivityDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 6/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

@MainActor
final class UserActivityDiContainer {
    
    let dataLayer: UserActivityDataLayerDependencies
    let domainLayer: UserActivityDomainLayerDependencies
    
    init(dataLayer: UserActivityDataLayerDependencies, domainLayer: UserActivityDomainLayerDependencies) {

        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
