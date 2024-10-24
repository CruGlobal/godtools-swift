//
//  StoreUserLessonProgressUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 9/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class StoreUserLessonProgressUseCase {
    
    private let storeLessonProgressRepository: StoreUserLessonProgressRepositoryInterface
    
    init(storeLessonProgressRepository: StoreUserLessonProgressRepositoryInterface) {
        self.storeLessonProgressRepository = storeLessonProgressRepository
    }
    
    func storeLessonProgress(lessonId: String, lastViewedPageId: String, lastViewedPageNumber: Int, totalPageCount: Int) -> AnyPublisher<UserLessonProgressDomainModel, Error> {
        
        return storeLessonProgressRepository.storeLessonProgress(
            lessonId: lessonId, 
            lastViewedPageId: lastViewedPageId,
            lastViewedPageNumber: lastViewedPageNumber,
            totalPageCount: totalPageCount
        )
    }
}
