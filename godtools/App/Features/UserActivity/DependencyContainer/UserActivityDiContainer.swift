//
//  UserActivityDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 6/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class UserActivityDiContainer {
    
    let dataLayer: UserActivityDataLayerDependencies
    let domainLayer: UserActivityDomainLayerDependencies
    
    init(core: AppCoreDiContainer) {
        
        dataLayer = UserActivityDataLayerDependencies(coreDataLayer: core.dataLayer)
        domainLayer = UserActivityDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
