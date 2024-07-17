//
//  CancelLessonEvaluationRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class CancelLessonEvaluationRepository: CancelLessonEvaluationRepositoryInterface {
    
    private let resourcesRepository: ResourcesRepository
    private let lessonEvaluationRepository: LessonEvaluationRepository
    
    init(resourcesRepository: ResourcesRepository, lessonEvaluationRepository: LessonEvaluationRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.lessonEvaluationRepository = lessonEvaluationRepository
    }
    
    func cancelPublisher(lessonId: String) -> AnyPublisher<Void, Never> {
        
        guard let lessonResource = resourcesRepository.getResource(id: lessonId) else {
            return Just(Void())
                .eraseToAnyPublisher()
        }
        
        lessonEvaluationRepository.storeLessonEvaluation(
            lesson: lessonResource,
            lessonEvaluated: false
        )
        
        return Just(Void())
            .eraseToAnyPublisher()
    }
}
