//
//  LessonFilterDiContainer.swift
//  godtools
//
//  Created by Rachael Skeath on 7/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class LessonFilterDiContainer {
    
    let dataLayer: LessonFilterDataLayerDependencies
    let domainLayer: LessonFilterDomainLayerDependencies
    
    init(core: AppCoreDiContainer) {
        
        dataLayer = LessonFilterDataLayerDependencies(coreDataLayer: core.dataLayer)
        domainLayer = LessonFilterDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
