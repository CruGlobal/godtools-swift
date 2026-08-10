//
//  LessonsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

@MainActor
final class LessonsDiContainer {
        
    let dataLayer: LessonsDataLayerDependencies
    let domainLayer: LessonsDomainLayerDependencies
    
    init(dataLayer: LessonsDataLayerDependencies, domainLayer: LessonsDomainLayerDependencies) {
        
        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
