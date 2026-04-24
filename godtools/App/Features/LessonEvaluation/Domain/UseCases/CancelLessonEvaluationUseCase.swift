//
//  CancelLessonEvaluationUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class CancelLessonEvaluationUseCase {
        
    private let resourcesRepository: ResourcesRepository
    private let lessonEvaluationRepository: LessonEvaluationRepository
    
    init(resourcesRepository: ResourcesRepository, lessonEvaluationRepository: LessonEvaluationRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.lessonEvaluationRepository = lessonEvaluationRepository
    }
    
    func execute(lessonId: String) -> AnyPublisher<Void, Never> {
        
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
                lessonEvaluated: false
            )
        }
        
        return Just(Void())
            .eraseToAnyPublisher()
    }
}
