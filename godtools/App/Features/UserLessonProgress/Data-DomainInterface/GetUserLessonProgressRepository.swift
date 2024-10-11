//
//  GetUserLessonProgressRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 9/24/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine
import GodToolsToolParser

class GetUserLessonProgressRepository: GetUserLessonProgressRepositoryInterface {
    
    private let lessonProgressRepository: UserLessonProgressRepository
    private let userCountersRepository: UserCountersRepository
    
    init(userLessonProgressRepository: UserLessonProgressRepository, userCountersRepository: UserCountersRepository) {
        self.lessonProgressRepository = userLessonProgressRepository
        self.userCountersRepository = userCountersRepository
    }
    
    func getLessonProgressChangedPublisher() -> AnyPublisher<Void, Never> {
        // TODO: - figure out how to work around this
        return lessonProgressRepository.getLessonProgressChangedPublisher()
    }
    
    func getLessonProgressPublisher(lessonId: String) -> AnyPublisher<UserLessonProgressDomainModel?, Never> {
        
        let lessonCompletionUserCounterId = UserCounterNames.shared.LESSON_COMPLETION(tool: lessonId)
        if let lessonCompletionUserCounter = self.userCountersRepository.getUserCounter(id: lessonCompletionUserCounterId){
            
            let completedDomainModel = UserLessonProgressDomainModel(
                lessonId: lessonId,
                lastViewedPageId: "",
                progress: 1
            )
            
            return Just(completedDomainModel)
                .eraseToAnyPublisher()
        }
        else if let lessonProgress = self.lessonProgressRepository.getLessonProgress(lessonId: lessonId) {
            
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
