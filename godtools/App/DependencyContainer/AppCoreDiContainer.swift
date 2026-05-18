//
//  AppCoreDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 5/18/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class AppCoreDiContainer {
    
    let dataLayer: AppDataLayerDependencies
    let domainLayer: AppDomainLayerDependencies
    
    init(dataLayer: AppDataLayerDependencies, domainLayer: AppDomainLayerDependencies) {
        
        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
