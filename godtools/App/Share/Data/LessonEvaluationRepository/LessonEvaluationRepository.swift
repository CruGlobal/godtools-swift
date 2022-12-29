//
//  LessonEvaluationRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class LessonEvaluationRepository {
    
    private let cache: LessonEvaluationRealmCache
    
    init(cache: LessonEvaluationRealmCache) {
        
        self.cache = cache
    }
    
    func getLessonEvaluation(lessonId: String) -> LessonEvaluationDataModel? {
        
        return cache.getLessonEvaluation(lessonId: lessonId)
    }
    
    func storeLessonEvaluation(lesson: ResourceModel, lessonEvaluated: Bool) {
                
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
        
        let lessonEvaluation = LessonEvaluationDataModel(
            lastEvaluationAttempt: Date(),
            lessonAbbreviation: lesson.abbreviation,
            lessonEvaluated: lessonIsEvaluated,
            lessonId: lesson.id,
            numberOfEvaluationAttempts: numberOfAttempts
        )
        
        cache.storeLessonEvaluation(lessonEvaluation: lessonEvaluation, completion: nil)
    }
}
