//
//  LessonSwipeTutorialViewedRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class LessonSwipeTutorialViewedRepository {
    
    private let cache: LessonSwipeTutorialViewedUserDefaultsCache
    
    init(cache: LessonSwipeTutorialViewedUserDefaultsCache) {
        self.cache = cache
    }
    
    func getLessonSwipeTutorialViewed() -> Bool {
        return cache.getLessonSwipeTutorialViewed()
    }
    
    func storeLessonSwipeTutorialViewed(viewed: Bool) {
        cache.storeLessonSwipeTutorialViewed(viewed: viewed)
    }
}
