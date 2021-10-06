//
//  LessonEvaluationRealmCache.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class LessonEvaluationRealmCache {
    
    private let realmDatabase: RealmDatabase
    
    required init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getLessonEvaluation(lessonId: String) -> LessonEvaluationModel? {
        
        if let cachedLessonEvaluation = getLessonEvaluation(realm: realmDatabase.mainThreadRealm, lessonId: lessonId) {
            
            return LessonEvaluationModel(
                lastEvaluationAttempt: cachedLessonEvaluation.lastEvaluationAttempt,
                lessonAbbreviation: cachedLessonEvaluation.lessonAbbreviation,
                lessonEvaluated: cachedLessonEvaluation.lessonEvaluated,
                lessonId: cachedLessonEvaluation.lessonId,
                numberOfEvaluationAttempts: cachedLessonEvaluation.numberOfEvaluationAttempts
            )
        }
        
        return nil
    }
    
    func storeLessonEvaluation(lessonEvaluation: LessonEvaluationModel, completion: ((_ error: Error?) -> Void)?) {
        
        realmDatabase.background { [weak self] (realm: Realm) in
                    
            var cacheError: Error?
            
            if let existingLessonEvaluation = self?.getLessonEvaluation(realm: realm, lessonId: lessonEvaluation.lessonId) {
                
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
                
                let newLessonEvaluation: RealmLessonEvaluation = RealmLessonEvaluation()
                newLessonEvaluation.mapFrom(model: lessonEvaluation, ignorePrimaryKey: false)
                
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
    
    private func getLessonEvaluation(realm: Realm, lessonId: String) -> RealmLessonEvaluation? {
        
        return realm.object(ofType: RealmLessonEvaluation.self, forPrimaryKey: lessonId)
    }
}
