//
//  LessonCompletionRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 9/24/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class LessonCompletionRepository {
    
    private let cache: RealmLessonCompletionCache
    
    init(cache: RealmLessonCompletionCache) {
        self.cache = cache
    }
    
    func getLessonCompletionChangedPublisher() -> AnyPublisher<Void, Never> {
        return cache.getUserLessonCompletionChangedPublisher()
    }
    
    func storeLessonCompletion(_ lessonCompletion: LessonCompletionDataModel) {
        cache.storeUserLessonCompletion(lessonCompletion)
    }
    
    func getLessonCompletion(lessonId: String) -> LessonCompletionDataModel? {
        return cache.getUserLessonCompletion(lessonId: lessonId)
    }
}
