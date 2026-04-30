//
//  UserLessonProgressRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 9/24/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class UserLessonProgressRepository {
    
    private let cache: UserLessonProgressCache
    
    init(cache: UserLessonProgressCache) {
        self.cache = cache
    }
    
    @MainActor func getLessonProgressChangedPublisher() -> AnyPublisher<Void, Never> {
        return cache.persistence
            .observeCollectionChangesPublisher()
            .catch { _ in
                return Just(Void())
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func storeLessonProgressPublisher(lessonId: String, lastViewedPageId: String, progress: Double) -> AnyPublisher<UserLessonProgressDataModel, Error> {
        
        return AnyPublisher() {
            
            try await self.storeLessonProgress(
                lessonId: lessonId,
                lastViewedPageId: lastViewedPageId,
                progress: progress
            )
        }
        .eraseToAnyPublisher()
    }
    
    private func storeLessonProgress(lessonId: String, lastViewedPageId: String, progress: Double) async throws -> UserLessonProgressDataModel {
        
        let dataModel = UserLessonProgressDataModel(
            id: lessonId,
            lessonId: lessonId,
            lastViewedPageId: lastViewedPageId,
            progress: progress
        )
        
        _ = try await cache.persistence.writeObjectsAsync(externalObjects: [dataModel], writeOption: nil, getOption: nil)
        
        return dataModel
    }
    
    func getLessonProgress(lessonId: String) -> UserLessonProgressDataModel? {
        
        do {
            return try cache.persistence.getDataModel(id: lessonId)
        }
        catch _ {
            return nil
        }
    }
}
