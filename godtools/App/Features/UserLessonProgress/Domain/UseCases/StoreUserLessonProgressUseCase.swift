//
//  StoreUserLessonProgressUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 9/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class StoreUserLessonProgressUseCase {
    
    private let lessonProgressRepository: UserLessonProgressRepository
    
    init(lessonProgressRepository: UserLessonProgressRepository) {
        self.lessonProgressRepository = lessonProgressRepository
    }
    
    func execute(lessonId: String, viewedPageId: String, viewedPageNumber: Int, totalPageCount: Int) async throws -> UserLessonProgressDomainModel {
        
        let firstPageNumber: Int = 0
        let isFirstPage: Bool = viewedPageNumber == firstPageNumber
        let pageCount: Int = totalPageCount - 1 // Excludes final things to try page. ~Levi
        
        guard !isFirstPage && pageCount > 0 else {
            return UserLessonProgressDomainModel(lessonId: lessonId, lastViewedPageId: viewedPageId, progress: 0)
        }
        
        let reachedCompletion: Bool = viewedPageNumber >= pageCount - 1
        
        let progress: Double = reachedCompletion ? 1 : Double(viewedPageNumber) / Double(pageCount)
        
        _ = try await lessonProgressRepository
            .storeLessonProgress(
                lessonId: lessonId,
                lastViewedPageId: viewedPageId,
                progress: progress
            )
        
        return UserLessonProgressDomainModel(
            lessonId: lessonId,
            lastViewedPageId: viewedPageId,
            progress: progress
        )
    }
}
