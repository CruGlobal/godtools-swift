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
        
        let finalThingsToTryPageCount: Int = 1
        let excludedPageCount: Int = finalThingsToTryPageCount // Excludes final things to try page. ~Levi
        let startingPageNumber: Int = 1
        let numberOfPages: Int = totalPageCount - excludedPageCount
        
        let pageNumber: Int = clampViewedPageNumber(viewedPageNumber: viewedPageNumber, min: startingPageNumber, max: numberOfPages, startingPageNumber: startingPageNumber)
        
        let isFirstPage: Bool = pageNumber == startingPageNumber
        
        guard numberOfPages > 0 else {
            return UserLessonProgressDomainModel(lessonId: lessonId, lastViewedPageId: viewedPageId, progress: 0)
        }
        
        let reachedCompletion: Bool = pageNumber >= numberOfPages
        
        let progress: Double
        
        if isFirstPage {
            progress = 0
        }
        else if reachedCompletion {
            progress = 1
        }
        else {
            progress = Double(pageNumber) / Double(numberOfPages + excludedPageCount)
        }
        
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
    
    private func clampViewedPageNumber(viewedPageNumber: Int, min: Int, max: Int, startingPageNumber: Int) -> Int {
                
        let initialPage: Int = viewedPageNumber + startingPageNumber
        
        let pageNumber: Int
        
        if initialPage < min {
            pageNumber = min
        }
        else if initialPage > max {
            pageNumber = max
        }
        else {
            pageNumber = initialPage
        }
        
        return pageNumber
    }
}
