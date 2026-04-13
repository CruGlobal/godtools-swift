//
//  LearnToShareToolDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 12/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class LearnToShareToolDiContainer {
    
    let dataLayer: LearnToShareToolDataLayerDependencies
    let domainLayer: LearnToShareToolDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies) {
        
        dataLayer = LearnToShareToolDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = LearnToShareToolDomainLayerDependencies(coreDataLayer: coreDataLayer, coreDomainLayer: coreDomainLayer, dataLayer: dataLayer)
    }
}
