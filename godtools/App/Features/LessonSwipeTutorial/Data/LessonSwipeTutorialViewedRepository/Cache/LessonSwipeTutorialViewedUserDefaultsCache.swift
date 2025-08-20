//
//  LessonSwipeTutorialViewedUserDefaultsCache.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class LessonSwipeTutorialViewedUserDefaultsCache {
    
    private let userDefaultsCache: UserDefaultsCacheInterface
    private let lessonSwipeTutorialViewedKey: String = "lessonSwipeTutorialViewed"
    
    init(userDefaultsCache: UserDefaultsCacheInterface) {
        self.userDefaultsCache = userDefaultsCache
    }
    
    func getLessonSwipeTutorialViewed() -> Bool {
        return userDefaultsCache.getValue(key: lessonSwipeTutorialViewedKey) as? Bool ?? false
    }
    
    func storeLessonSwipeTutorialViewed(viewed: Bool) {
        
        userDefaultsCache.cache(value: viewed, forKey: lessonSwipeTutorialViewedKey)
        userDefaultsCache.commitChanges()
    }
}
