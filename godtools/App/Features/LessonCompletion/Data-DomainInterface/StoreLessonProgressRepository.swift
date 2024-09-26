//
//  StoreLessonProgressRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 9/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class StoreLessonProgressRepository: StoreLessonProgressRepositoryInterface {
    
    private let lessonCompletionRepository: LessonCompletionRepository
    
    init(lessonCompletionRepository: LessonCompletionRepository) {
        self.lessonCompletionRepository = lessonCompletionRepository
    }
    
    func storeLessonProgress(lessonId: String, lastViewedPageId: String, lastViewedPageNumber: Int, totalPageCount: Int) -> AnyPublisher<Void, Never> {
        
        let lessonCompletion = LessonCompletionDataModel(lessonId: lessonId, progress: Double(lastViewedPageNumber / totalPageCount))
        
        lessonCompletionRepository.storeLessonCompletion(lessonCompletion)
        
        return Just(Void())
            .eraseToAnyPublisher()
    }
}
