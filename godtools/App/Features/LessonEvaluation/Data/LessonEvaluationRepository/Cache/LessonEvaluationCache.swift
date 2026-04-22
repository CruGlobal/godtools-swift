//
//  LessonEvaluationCache.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

final class LessonEvaluationCache {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getLessonEvaluation(lessonId: String) throws -> LessonEvaluationDataModel? {
        
        guard let cachedLessonEvaluation = try realmDatabase.openRealm().object(ofType: RealmLessonEvaluation.self, forPrimaryKey: lessonId) else {
            return nil
        }
        
        return LessonEvaluationDataModel(
            id: cachedLessonEvaluation.lessonId,
            lastEvaluationAttempt: cachedLessonEvaluation.lastEvaluationAttempt,
            lessonAbbreviation: cachedLessonEvaluation.lessonAbbreviation,
            lessonEvaluated: cachedLessonEvaluation.lessonEvaluated,
            lessonId: cachedLessonEvaluation.lessonId,
            numberOfEvaluationAttempts: cachedLessonEvaluation.numberOfEvaluationAttempts
        )
    }
    
    func storeLessonEvaluation(lessonEvaluation: LessonEvaluationDataModel, completion: ((_ error: Error?) -> Void)?) {
        
        realmDatabase.write.serialAsync { result in
            
            switch result {
            
            case .success(let realm):
                
                let realmLessonEvaluation = RealmLessonEvaluation.createNewFrom(model: lessonEvaluation)
            
                do {
                    try realm.write {
                        realm.add(realmLessonEvaluation, update: .modified)
                    }
                }
                catch let error {
                    completion?(error)
                }
                
            case .failure(let error):
                completion?(error)
            }
        }
    }
}
