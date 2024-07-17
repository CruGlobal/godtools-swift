//
//  FeaturedLessonsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class FeaturedLessonsDomainLayerDependencies {
    
    private let dataLayer: FeaturedLessonsDataLayerDependencies
    
    init(dataLayer: FeaturedLessonsDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getFeaturedLessonsUseCase() -> GetFeaturedLessonsUseCase {
        
        return GetFeaturedLessonsUseCase(
            getFeaturedLessonsRepository: dataLayer.getFeaturedLessonsRepositoryInterface()
        )
    }
}
