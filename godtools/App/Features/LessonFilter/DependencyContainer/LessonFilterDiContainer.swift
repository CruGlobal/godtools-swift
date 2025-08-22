//
//  LessonFilterDiContainer.swift
//  godtools
//
//  Created by Rachael Skeath on 7/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class LessonFilterDiContainer {
    
    let dataLayer: LessonFilterDataLayerDependencies
    let domainLayer: LessonFilterDomainLayerDependencies
    
    init(coreDataLayer: CoreDataLayerDependenciesInterface) {
        
        dataLayer = LessonFilterDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = LessonFilterDomainLayerDependencies(dataLayer: dataLayer)
    }
}
