//
//  UserActivityDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 6/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class UserActivityDomainLayerDependencies {
    
    private let dataLayer: UserActivityDataLayerDependencies
    private let coreDataLayer: AppDataLayerDependencies
    
    init(dataLayer: UserActivityDataLayerDependencies, coreDataLayer: AppDataLayerDependencies) {
        
        self.dataLayer = dataLayer
        self.coreDataLayer = coreDataLayer
    }
}
