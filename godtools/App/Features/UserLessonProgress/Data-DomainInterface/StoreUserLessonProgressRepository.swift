//
//  StoreUserLessonProgressRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 9/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class StoreUserLessonProgressRepository: StoreUserLessonProgressRepositoryInterface {
    
    private let lessonProgressRepository: UserLessonProgressRepository
    
    init(lessonProgressRepository: UserLessonProgressRepository) {
        self.lessonProgressRepository = lessonProgressRepository
    }
    
    func storeLessonProgress(lessonId: String, lastViewedPageId: String, lastViewedPageNumber: Int, totalPageCount: Int) -> AnyPublisher<Void, Never> {
        
        let lessonProgress = UserLessonProgressDataModel(
            lessonId: lessonId,
            lastViewedPageId: lastViewedPageId,
            progress: Double(lastViewedPageNumber) / Double(totalPageCount)
        )
        
        lessonProgressRepository.storeLessonProgress(lessonProgress)
        
        return Just(Void())
            .eraseToAnyPublisher()
    }
}
