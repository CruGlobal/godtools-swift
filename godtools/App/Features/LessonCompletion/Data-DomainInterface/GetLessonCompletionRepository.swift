//
//  GetLessonCompletionRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 9/24/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLessonCompletionRepository: GetLessonCompletionRepositoryInterface {
    
    private let lessonCompletionRepository: LessonCompletionRepository
    
    init(lessonCompletionRepository: LessonCompletionRepository) {
        self.lessonCompletionRepository = lessonCompletionRepository
    }
    
    func getLessonCompletionPublisher(lessonId: String) -> AnyPublisher<LessonCompletionDomainModel?, Never> {
        
        if let lessonCompletion = lessonCompletionRepository.getLessonCompletion(lessonId: lessonId) {
            
            let domainModel = LessonCompletionDomainModel(lessonId: lessonId, progress: lessonCompletion.progress)
            
            return Just(domainModel)
                .eraseToAnyPublisher()
        } else {
            
            return Just(nil)
                .eraseToAnyPublisher()
        }
    }
}
