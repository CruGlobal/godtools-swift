//
//  EvaluateLessonUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class EvaluateLessonUseCase: Sendable {
    
    private let resourcesRepository: ResourcesRepository
    private let lessonEvaluationRepository: LessonEvaluationRepository
    private let lessonFeedbackAnalytics: LessonFeedbackAnalytics
    
    init(
        resourcesRepository: ResourcesRepository,
        lessonEvaluationRepository: LessonEvaluationRepository,
        lessonFeedbackAnalytics: LessonFeedbackAnalytics
    ) {
        
        self.resourcesRepository = resourcesRepository
        self.lessonEvaluationRepository = lessonEvaluationRepository
        self.lessonFeedbackAnalytics = lessonFeedbackAnalytics
    }
    
    func execute(
        lessonId: String,
        feedback: TrackLessonFeedbackDomainModel,
        lessonLanguage: AppLanguageDomainModel
    ) async throws {
        
        let lessonResource: ResourceDataModel? = resourcesRepository.getResourceById(id: lessonId)
        
        guard let lessonResource = lessonResource else {
            return
        }
        
        try await lessonEvaluationRepository.storeLessonEvaluation(
            lesson: lessonResource,
            lessonEvaluated: true
        )

        await lessonFeedbackAnalytics.trackLessonFeedback(
            lesson: lessonResource,
            feedback: feedback,
            contentLanguage: lessonLanguage
        )
    }
}
