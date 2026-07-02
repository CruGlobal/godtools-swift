//
//  PersonalizedToolsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class PersonalizedToolsDiContainer {

    private let dataLayer: PersonalizedToolsDataLayerDependencies

    let domainLayer: PersonalizedToolsDomainLayerDependencies
    
    init(core: AppCoreDiContainer, personalizedToolsDataLayer: PersonalizedToolsDataLayerDependencies) {
        
        self.dataLayer = personalizedToolsDataLayer
        self.domainLayer = PersonalizedToolsDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
