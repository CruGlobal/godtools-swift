//
//  UserLessonProgressRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 9/24/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class UserLessonProgressRepository {
    
    private let cache: RealmUserLessonProgressCache
    
    init(cache: RealmUserLessonProgressCache) {
        self.cache = cache
    }
    
    @MainActor func getLessonProgressChangedPublisher() -> AnyPublisher<Void, Never> {
        return cache.getUserLessonProgressChangedPublisher()
    }
    
    func storeLessonProgress(_ lessonProgress: UserLessonProgressDataModel) -> AnyPublisher<UserLessonProgressDataModel, Error> {
        cache.storeUserLessonProgress(lessonProgress)
    }
    
    func getLessonProgress(lessonId: String) -> UserLessonProgressDataModel? {
        return cache.getUserLessonProgress(lessonId: lessonId)
    }
}
