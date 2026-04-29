//
//  LessonSwipeTutorialDataLayerDependencies.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class LessonSwipeTutorialDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        self.coreDataLayer = coreDataLayer
    }
    
    func getLessonSwipeTutorialViewedRepository() -> LessonSwipeTutorialViewedRepository {
        return LessonSwipeTutorialViewedRepository(
            cache: LessonSwipeTutorialViewedUserDefaultsCache(
                userDefaultsCache: coreDataLayer.getUserDefaultsCache()
            )
        )
    }
}
