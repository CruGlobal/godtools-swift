//
//  UserLessonFiltersRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 7/3/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class UserLessonFiltersRepository {
    
    static let userFilterId = "userLessonLanguageFilter"
    
    private let cache: UserLessonFiltersCache
    
    init(cache: UserLessonFiltersCache) {
        self.cache = cache
    }
    
    @MainActor func observeCollectionChangesPublisher() -> AnyPublisher<Void, Error> {
        return cache
            .persistence
            .observeCollectionChangesPublisher()
            .eraseToAnyPublisher()
    }
    
    func getUserLessonLanguageFilter() -> UserLessonLanguageFilterDataModel? {
        
        do {
            return try cache.persistence.getDataModel(id: Self.userFilterId)
        }
        catch _ {
            return nil
        }
    }
    
    func storeUserLessonLanguageFilter(languageId: String) async throws {
        
        let dataModel = UserLessonLanguageFilterDataModel(
            id: Self.userFilterId,
            createdAt: Date(),
            languageId: languageId,
            filterId: Self.userFilterId
        )
        
        _ = try await cache.persistence.writeObjects(
            externalObjects: [dataModel],
            writeOption: nil,
            getOption: nil
        )
    }
}
