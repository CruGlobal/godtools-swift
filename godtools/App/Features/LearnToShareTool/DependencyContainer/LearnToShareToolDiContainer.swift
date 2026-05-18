//
//  LearnToShareToolDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 12/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class LearnToShareToolDiContainer {
    
    let dataLayer: LearnToShareToolDataLayerDependencies
    let domainLayer: LearnToShareToolDomainLayerDependencies
    
    init(core: AppCoreDiContainer) {
        
        dataLayer = LearnToShareToolDataLayerDependencies(coreDataLayer: core.dataLayer)
        domainLayer = LearnToShareToolDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
