//
//  PersonalizedToolsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class PersonalizedToolsDiContainer {
        
    private let dataLayer: PersonalizedToolsDataLayerDependencies
    private let domainInterfaceLayer: PersonalizedToolsDomainInterfaceDependencies
    
    let domainLayer: PersonalizedToolsDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        let dataLayer = PersonalizedToolsDataLayerDependencies(coreDataLayer: coreDataLayer)
        
        self.dataLayer = dataLayer
        self.domainInterfaceLayer = PersonalizedToolsDomainInterfaceDependencies(coreDataLayer: coreDataLayer, dataLayer: dataLayer)
        domainLayer = PersonalizedToolsDomainLayerDependencies(domainInterfaceLayer: domainInterfaceLayer)
    }
}
