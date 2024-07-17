//
//  EvaluateLessonUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class EvaluateLessonUseCase {
    
    private let evaluateLessonRepositoryInterface: EvaluateLessonRepositoryInterface
    
    init(evaluateLessonRepositoryInterface: EvaluateLessonRepositoryInterface) {
        
        self.evaluateLessonRepositoryInterface = evaluateLessonRepositoryInterface
    }
    
    func evaluateLessonPublisher(lessonId: String, feedback: TrackLessonFeedbackDomainModel) -> AnyPublisher<Void, Never> {
        
        return evaluateLessonRepositoryInterface.evaluateLessonPublisher(lessonId: lessonId, feedback: feedback)
            .eraseToAnyPublisher()
    }
}
