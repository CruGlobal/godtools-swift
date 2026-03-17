//
//  UserActivityDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 6/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class UserActivityDiContainer {
    
    let dataLayer: UserActivityDataLayerDependencies
    let domainLayer: UserActivityDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies) {
        
        dataLayer = UserActivityDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = UserActivityDomainLayerDependencies(coreDataLayer: coreDataLayer, coreDomainLayer: coreDomainLayer, dataLayer: dataLayer)
    }
}
