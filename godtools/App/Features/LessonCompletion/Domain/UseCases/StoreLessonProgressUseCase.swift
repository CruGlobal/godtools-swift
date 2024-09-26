//
//  StoreLessonProgressUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 9/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class StoreLessonProgressUseCase {
    
    private let storeLessonProgressRepository: StoreLessonProgressRepositoryInterface
    
    init(storeLessonProgressRepository: StoreLessonProgressRepositoryInterface) {
        self.storeLessonProgressRepository = storeLessonProgressRepository
    }
    
    func storeLessonProgress(lessonId: String, lastViewedPageId: String, lastViewedPageNumber: Int, totalPageCount: Int) -> AnyPublisher<Void, Never> {
        
        return storeLessonProgressRepository.storeLessonProgress(
            lessonId: lessonId, lastViewedPageId:
                lastViewedPageId,
            lastViewedPageNumber: lastViewedPageNumber,
            totalPageCount: totalPageCount
        )
    }
}
