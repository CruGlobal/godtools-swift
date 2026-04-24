//
//  EvaluateLessonUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class EvaluateLessonUseCase {
    
    private let resourcesRepository: ResourcesRepository
    private let lessonEvaluationRepository: LessonEvaluationRepository
    private let lessonFeedbackAnalytics: LessonFeedbackAnalytics
    
    init(resourcesRepository: ResourcesRepository, lessonEvaluationRepository: LessonEvaluationRepository, lessonFeedbackAnalytics: LessonFeedbackAnalytics) {
        
        self.resourcesRepository = resourcesRepository
        self.lessonEvaluationRepository = lessonEvaluationRepository
        self.lessonFeedbackAnalytics = lessonFeedbackAnalytics
    }
    
    func execute(lessonId: String, feedback: TrackLessonFeedbackDomainModel) -> AnyPublisher<Void, Never> {
        
        let lessonResource: ResourceDataModel?
        
        do {
            lessonResource = try resourcesRepository.persistence.getDataModel(id: lessonId)
        }
        catch _ {
            lessonResource = nil
        }
        
        guard let lessonResource = lessonResource else {
            return Just(Void())
                .eraseToAnyPublisher()
        }
        
        Task {
            try await lessonEvaluationRepository.storeLessonEvaluation(
                lesson: lessonResource,
                lessonEvaluated: true
            )
        }

        lessonFeedbackAnalytics.trackLessonFeedback(
            lesson: lessonResource,
            feedback: feedback
        )
        
        return Just(Void())
            .eraseToAnyPublisher()
    }
}
