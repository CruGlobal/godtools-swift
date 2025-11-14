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
    
    private let resourcesRepository: ResourcesRepository
    private let lessonEvaluationRepository: LessonEvaluationRepository
    private let lessonFeedbackAnalytics: LessonFeedbackAnalytics
    
    init(resourcesRepository: ResourcesRepository, lessonEvaluationRepository: LessonEvaluationRepository, lessonFeedbackAnalytics: LessonFeedbackAnalytics) {
        
        self.resourcesRepository = resourcesRepository
        self.lessonEvaluationRepository = lessonEvaluationRepository
        self.lessonFeedbackAnalytics = lessonFeedbackAnalytics
    }
    
    func execute(lessonId: String, feedback: TrackLessonFeedback) -> AnyPublisher<Void, Never> {
        
        guard let lessonResource = resourcesRepository.persistence.getObject(id: lessonId) else {
            return Just(Void())
                .eraseToAnyPublisher()
        }
        
        lessonEvaluationRepository.storeLessonEvaluation(
            lesson: lessonResource,
            lessonEvaluated: true
        )
        
        lessonFeedbackAnalytics.trackLessonFeedback(
            lesson: lessonResource,
            feedback: feedback
        )
        
        return Just(Void())
            .eraseToAnyPublisher()
    }
}
