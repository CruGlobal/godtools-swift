//
//  LessonSwipeTutorialViewedRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

final class LessonSwipeTutorialViewedRepository: Sendable {
    
    private let cache: LessonSwipeTutorialViewedUserDefaultsCache
    
    init(cache: LessonSwipeTutorialViewedUserDefaultsCache) {
        self.cache = cache
    }
    
    func getLessonSwipeTutorialViewed() async -> Bool {
        return await cache.getLessonSwipeTutorialViewed()
    }
    
    func storeLessonSwipeTutorialViewed(viewed: Bool) async {
        await cache.storeLessonSwipeTutorialViewed(viewed: viewed)
    }
}
