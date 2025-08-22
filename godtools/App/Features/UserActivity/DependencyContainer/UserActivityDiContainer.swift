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
    
    init(coreDataLayer: CoreDataLayerDependenciesInterface) {
        
        dataLayer = UserActivityDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = UserActivityDomainLayerDependencies(dataLayer: dataLayer, coreDataLayer: coreDataLayer)
    }
}
