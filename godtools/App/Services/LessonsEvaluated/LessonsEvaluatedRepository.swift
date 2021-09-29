//
//  LessonsEvaluatedRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class LessonsEvaluatedRepository {
    
    private let cache: LessonsEvaluatedRealmCache
    
    required init(cache: LessonsEvaluatedRealmCache) {
        
        self.cache = cache
    }
    
    func getEvaluatedLesson(lessonId: String) -> EvaluatedLessonModel? {
        
        return cache.getEvaluatedLesson(lessonId: lessonId)
    }
    
    func storeEvaluatedLesson(lessonId: String, lessonAbbreviation: String) {
        
        let model = EvaluatedLessonModel(lessonAbbreviation: lessonAbbreviation, lessonId: lessonId)
        
        cache.storeEvaluatedLesson(evaluatedLesson: model, completion: nil)
    }
}
