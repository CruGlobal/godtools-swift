//
//  CancelLessonEvaluationUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class CancelLessonEvaluationUseCase {
        
    private let resourcesRepository: ResourcesRepository
    private let lessonEvaluationRepository: LessonEvaluationRepository
    
    init(resourcesRepository: ResourcesRepository, lessonEvaluationRepository: LessonEvaluationRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.lessonEvaluationRepository = lessonEvaluationRepository
    }
    
    func execute(lessonId: String) async throws {
        
        let lessonResource: ResourceDataModel? = resourcesRepository.getResourceById(id: lessonId)

        guard let lessonResource = lessonResource else {
            return
        }
        
        try await lessonEvaluationRepository.storeLessonEvaluation(
            lesson: lessonResource,
            lessonEvaluated: false
        )
    }
}
