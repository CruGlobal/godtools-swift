//
//  FeaturedLessonsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class FeaturedLessonsDiContainer: Sendable {
    
    let dataLayer: FeaturedLessonsDataLayerDependencies
    let domainLayer: FeaturedLessonsDomainLayerDependencies
    
    init(dataLayer: FeaturedLessonsDataLayerDependencies, domainLayer: FeaturedLessonsDomainLayerDependencies) {

        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
