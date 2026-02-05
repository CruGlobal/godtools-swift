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
    
    let domainLayer: PersonalizedToolsDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainlayer: AppDomainLayerDependencies) {
        
        self.dataLayer = PersonalizedToolsDataLayerDependencies(coreDataLayer: coreDataLayer)
        self.domainLayer = PersonalizedToolsDomainLayerDependencies(coreDataLayer: coreDataLayer, dataLayer: dataLayer, coreDomainlayer: coreDomainlayer)
    }
}
