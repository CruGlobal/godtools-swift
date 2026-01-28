//
//  UserLessonFiltersRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 7/3/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class UserLessonFiltersRepository {
    
    static let filterId = "userLessonLanguageFilter"
    
    private let cache: RealmUserLessonFiltersCache
    
    init(cache: RealmUserLessonFiltersCache) {
        self.cache = cache
    }
    
    @MainActor func getUserLessonLanguageFilterChangedPublisher() -> AnyPublisher<Void, Never> {
        return cache.getUserLessonLanguageFilterChangedPublisher()
    }
    
    func storeUserLessonLanguageFilter(with id: String) {
        cache.storeUserLessonLanguageFilter(languageId: id, filterId: UserLessonFiltersRepository.filterId)
    }
    
    func getUserLessonLanguageFilter() -> UserLessonLanguageFilterDataModel? {
        return cache.getUserLessonLanguageFilter(filterId: UserLessonFiltersRepository.filterId)
    }
}
