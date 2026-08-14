//
//  UserLessonProgressRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 9/24/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class UserLessonProgressRepository: Sendable {
    
    private let cache: UserLessonProgressCache
    
    init(cache: UserLessonProgressCache) {
        self.cache = cache
    }
    
    @MainActor func getLessonProgressChangedPublisher() -> AnyPublisher<Void, Error> {
        return cache.persistence
            .observeCollectionChangesPublisher()
            .eraseToAnyPublisher()
    }
    
    func getLessonProgress(lessonId: String) -> UserLessonProgressDataModel? {
        
        do {
            return try cache.persistence.getDataModel(id: lessonId)
        }
        catch _ {
            return nil
        }
    }
    
    func storeLessonProgress(lessonId: String, lastViewedPageId: String, progress: Double) async throws -> UserLessonProgressDataModel {
        
        let dataModel = UserLessonProgressDataModel(
            id: lessonId,
            lessonId: lessonId,
            lastViewedPageId: lastViewedPageId,
            progress: progress
        )
        
        _ = try await cache.persistence.writeObjects(externalObjects: [dataModel], writeOption: nil, getOption: nil)
        
        return dataModel
    }
}
