//
//  LessonSwipeTutorialViewedUserDefaultsCache.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class LessonSwipeTutorialViewedUserDefaultsCache: Sendable {
    
    private let userDefaultsCache: UserDefaultsCacheInterface
    private let lessonSwipeTutorialViewedKey: String = "lessonSwipeTutorialViewed"
    
    init(userDefaultsCache: UserDefaultsCacheInterface) {
        self.userDefaultsCache = userDefaultsCache
    }
    
    func getLessonSwipeTutorialViewed() async -> Bool {

        let viewed: Bool? = await userDefaultsCache.getBool(key: lessonSwipeTutorialViewedKey)

        return viewed ?? false
    }

    func storeLessonSwipeTutorialViewed(viewed: Bool) async {

        await userDefaultsCache.storeBool(value: viewed, forKey: lessonSwipeTutorialViewedKey)
        await userDefaultsCache.commitChanges()
    }
}
