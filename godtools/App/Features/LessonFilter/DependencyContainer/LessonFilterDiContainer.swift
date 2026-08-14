//
//  LessonFilterDiContainer.swift
//  godtools
//
//  Created by Rachael Skeath on 7/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class LessonFilterDiContainer: Sendable {
    
    let dataLayer: LessonFilterDataLayerDependencies
    let domainLayer: LessonFilterDomainLayerDependencies
    
    init(dataLayer: LessonFilterDataLayerDependencies, domainLayer: LessonFilterDomainLayerDependencies) {

        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
