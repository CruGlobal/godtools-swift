//
//  LessonEvaluationRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

final class LessonEvaluationRepository {
    
    private let cache: LessonEvaluationCache
    
    init(cache: LessonEvaluationCache) {
        
        self.cache = cache
    }
    
    func getLessonEvaluation(lessonId: String) -> LessonEvaluationDataModel? {
        
        do {
            return try cache.persistence.getDataModel(id: lessonId)
        }
        catch _ {
            return nil
        }
    }
    
    func storeLessonEvaluation(lesson: ResourceDataModel, lessonEvaluated: Bool) async throws {
                
        let cachedLessonIsEvaluated: Bool
        let numberOfAttempts: Int
        
        if let cachedLessonEvaluation = getLessonEvaluation(lessonId: lesson.id) {
            cachedLessonIsEvaluated = cachedLessonEvaluation.lessonEvaluated
            numberOfAttempts = cachedLessonEvaluation.numberOfEvaluationAttempts + 1
        }
        else {
            cachedLessonIsEvaluated = false
            numberOfAttempts = 1
        }
        
        let lessonIsEvaluated: Bool
        
        // prevent a cached lesson marked as evaluated from getting set to false.
        if cachedLessonIsEvaluated {
            lessonIsEvaluated = true
        }
        else {
            lessonIsEvaluated = lessonEvaluated
        }
        
        let id: String = lesson.id
        
        let lessonEvaluation = LessonEvaluationDataModel(
            id: id,
            lastEvaluationAttempt: Date(),
            lessonAbbreviation: lesson.abbreviation,
            lessonEvaluated: lessonIsEvaluated,
            lessonId: id,
            numberOfEvaluationAttempts: numberOfAttempts
        )
        
        _ = try await cache.persistence.writeObjectsAsync(
            externalObjects: [lessonEvaluation],
            writeOption: nil,
            getOption: nil
        )
    }
}
