//
//  TutorialDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class TutorialDiContainer {
    
    let dataLayer: TutorialDataLayerDependencies
    let domainLayer: TutorialDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = TutorialDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = TutorialDomainLayerDependencies(coreDataLayer: coreDataLayer, dataLayer: dataLayer)
    }
}
