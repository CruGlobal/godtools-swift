//
//  LessonEvaluationRealmCache.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import RealmSwift

final class LessonEvaluationRealmCache {
    
    private let realmDatabase: LegacyRealmDatabase
    
    init(realmDatabase: LegacyRealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getLessonEvaluation(lessonId: String) -> LessonEvaluationDataModel? {
        
        guard let cachedLessonEvaluation = realmDatabase.openRealm().object(ofType: RealmLessonEvaluation.self, forPrimaryKey: lessonId) else {
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
        
        realmDatabase.background { (realm: Realm) in
                    
            var cacheError: Error?
            
            if let existingLessonEvaluation = realm.object(ofType: RealmLessonEvaluation.self, forPrimaryKey: lessonEvaluation.lessonId) {
                
                do {
                    try realm.write {
                        existingLessonEvaluation.mapFrom(model: lessonEvaluation, ignorePrimaryKey: true)
                    }
                }
                catch let error {
                    cacheError = error
                }
            }
            else {
                
                let newLessonEvaluation = RealmLessonEvaluation.createNewFrom(model: lessonEvaluation)
                
                do {
                    try realm.write {
                        realm.add(newLessonEvaluation)
                    }
                }
                catch let error {
                    cacheError = error
                }
            }
            
            completion?(cacheError)
        }
    }
}
