//
//  GetLessonEvaluated.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLessonEvaluated {
    
    private let lessonEvaluationRepository: LessonEvaluationRepository
    
    init(lessonEvaluationRepository: LessonEvaluationRepository) {
        
        self.lessonEvaluationRepository = lessonEvaluationRepository
    }
    
    func execute(lessonId: String) -> AnyPublisher<Bool, Never> {
        
        guard let lessonEvaluation = lessonEvaluationRepository.getLessonEvaluation(lessonId: lessonId) else {
            return Just(false)
                .eraseToAnyPublisher()
        }
        
        let lessonEvaluated: Bool = lessonEvaluation.lessonEvaluated || lessonEvaluation.numberOfEvaluationAttempts > 0
        
        return Just(lessonEvaluated)
            .eraseToAnyPublisher()
    }
}
