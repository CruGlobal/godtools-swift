//
//  PersonalizedToolsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class PersonalizedToolsDomainLayerDependencies {
    
    private let domainInterfaceLayer: PersonalizedToolsDomainInterfaceDependencies
    
    init(domainInterfaceLayer: PersonalizedToolsDomainInterfaceDependencies) {
        
        self.domainInterfaceLayer = domainInterfaceLayer
    }
}
