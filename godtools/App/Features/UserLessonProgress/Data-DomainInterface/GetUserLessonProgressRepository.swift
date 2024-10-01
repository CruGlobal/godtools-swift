//
//  GetUserLessonProgressRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 9/24/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetUserLessonProgressRepository: GetUserLessonProgressRepositoryInterface {
    
    private let lessonProgressRepository: UserLessonProgressRepository
    
    init(userLessonProgressRepository: UserLessonProgressRepository) {
        self.lessonProgressRepository = userLessonProgressRepository
    }
    
    func getLessonProgressPublisher(lessonId: String) -> AnyPublisher<UserLessonProgressDomainModel?, Never> {
        
        if let lessonProgress = lessonProgressRepository.getLessonProgress(lessonId: lessonId) {
            
            let domainModel = UserLessonProgressDomainModel(
                lessonId: lessonId,
                lastViewedPageId: lessonProgress.lastViewedPageId,
                progress: lessonProgress.progress
            )
            
            return Just(domainModel)
                .eraseToAnyPublisher()
        } else {
            
            return Just(nil)
                .eraseToAnyPublisher()
        }
    }
}
