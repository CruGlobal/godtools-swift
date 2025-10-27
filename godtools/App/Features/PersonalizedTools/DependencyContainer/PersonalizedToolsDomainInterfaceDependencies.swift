//
//  PersonalizedToolsDomainInterfaceDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class PersonalizedToolsDomainInterfaceDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: PersonalizedToolsDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: PersonalizedToolsDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }
}
