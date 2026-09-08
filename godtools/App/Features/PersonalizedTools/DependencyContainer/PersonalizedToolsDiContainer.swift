//
//  PersonalizedToolsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class PersonalizedToolsDiContainer: Sendable {

    let dataLayer: PersonalizedToolsDataLayerDependencies
    let domainLayer: PersonalizedToolsDomainLayerDependencies
    
    init(dataLayer: PersonalizedToolsDataLayerDependencies, domainLayer: PersonalizedToolsDomainLayerDependencies) {
        
        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
