//
//  LessonSwipeTutorialViewedUserDefaultsCache.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class LessonSwipeTutorialViewedUserDefaultsCache {
    
    private let sharedUserDefaultsCache: SharedUserDefaultsCache
    private let lessonSwipeTutorialViewedKey: String = "lessonSwipeTutorialViewed"
    
    init(sharedUserDefaultsCache: SharedUserDefaultsCache) {
        self.sharedUserDefaultsCache = sharedUserDefaultsCache
    }
    
    func getLessonSwipeTutorialViewed() -> Bool {
        return sharedUserDefaultsCache.getValue(key: lessonSwipeTutorialViewedKey) as? Bool ?? false
    }
    
    func storeLessonSwipeTutorialViewed(viewed: Bool) {
        
        sharedUserDefaultsCache.cache(value: viewed, forKey: lessonSwipeTutorialViewedKey)
        sharedUserDefaultsCache.commitChanges()
    }
}
