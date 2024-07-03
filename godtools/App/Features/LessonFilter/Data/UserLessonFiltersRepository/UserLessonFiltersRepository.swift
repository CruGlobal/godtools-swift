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
    
    private let cache: RealmUserLessonFiltersCache
    
    init(cache: RealmUserLessonFiltersCache) {
        self.cache = cache
    }
    
    func getUserLessonLanguageFilterChangedPublisher() -> AnyPublisher<Void, Never> {
        return cache.getUserLessonLanguageFilterChangedPublisher()
    }
    
    func storeUserLessonLanguageFilter(with id: String) {
        cache.storeUserLessonLanguageFilter(languageId: id)
    }
    
    func getUserLessonLanguageFilter() -> UserLessonLanguageFilterDataModel? {
        return cache.getUserLessonLanguageFilter()
    }
}
