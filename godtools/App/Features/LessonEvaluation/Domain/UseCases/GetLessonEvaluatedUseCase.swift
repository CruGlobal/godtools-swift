//
//  GetLessonEvaluatedUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetLessonEvaluatedUseCase: Sendable {
    
    private let lessonEvaluationRepository: LessonEvaluationRepository
    
    init(lessonEvaluationRepository: LessonEvaluationRepository) {
        
        self.lessonEvaluationRepository = lessonEvaluationRepository
    }
    
    func execute(lessonId: String) -> Bool {
        
        guard let lessonEvaluation = lessonEvaluationRepository.getLessonEvaluation(lessonId: lessonId) else {
            return false
        }
        
        let lessonEvaluated: Bool = lessonEvaluation.lessonEvaluated || lessonEvaluation.numberOfEvaluationAttempts > 0
        
        return lessonEvaluated
    }
}
