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
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainlayer: AppDomainLayerDependencies, personalizedToolsDataLayer: PersonalizedToolsDataLayerDependencies) {
        
        dataLayer = LessonsDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = LessonsDomainLayerDependencies(coreDataLayer: coreDataLayer, dataLayer: dataLayer, coreDomainlayer: coreDomainlayer, personalizedToolsDataLayer: personalizedToolsDataLayer)
    }
}
