//
//  LessonsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class LessonsDiContainer {
        
    let dataLayer: LessonsDataLayerDependencies
    let domainLayer: LessonsDomainLayerDependencies
    
    init(core: AppCoreDiContainer, personalizedToolsDataLayer: PersonalizedToolsDataLayerDependencies) {
        
        dataLayer = LessonsDataLayerDependencies(coreDataLayer: core.dataLayer)
        domainLayer = LessonsDomainLayerDependencies(core: core, dataLayer: dataLayer, personalizedToolsDataLayer: personalizedToolsDataLayer)
    }
}
