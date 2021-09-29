//
//  LessonsEvaluatedRealmCache.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class LessonsEvaluatedRealmCache {
    
    private let realmDatabase: RealmDatabase
    
    required init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getEvaluatedLesson(lessonId: String) -> EvaluatedLessonModel? {
        
        if let cachedEvaluatedLesson = getEvaluatedLesson(realm: realmDatabase.mainThreadRealm, lessonId: lessonId) {
            
            return EvaluatedLessonModel(
                lessonAbbreviation: cachedEvaluatedLesson.lessonAbbreviation,
                lessonId: cachedEvaluatedLesson.lessonId
            )
        }
        
        return nil
    }
    
    func storeEvaluatedLesson(evaluatedLesson: EvaluatedLessonModel, completion: ((_ error: Error?) -> Void)?) {
        
        realmDatabase.background { [weak self] (realm: Realm) in
                    
            var cacheError: Error?
            
            if let existingEvaluatedLesson = self?.getEvaluatedLesson(realm: realm, lessonId: evaluatedLesson.lessonId) {
                
                do {
                    try realm.write {
                        existingEvaluatedLesson.mapFrom(model: evaluatedLesson, ignorePrimaryKey: true)
                    }
                }
                catch let error {
                    cacheError = error
                }
            }
            else {
                
                let newEvaluatedLesson: RealmEvaluatedLesson = RealmEvaluatedLesson()
                newEvaluatedLesson.mapFrom(model: evaluatedLesson, ignorePrimaryKey: false)
                
                do {
                    try realm.write {
                        realm.add(newEvaluatedLesson)
                    }
                }
                catch let error {
                    cacheError = error
                }
            }
            
            completion?(cacheError)
        }
    }
    
    private func getEvaluatedLesson(realm: Realm, lessonId: String) -> RealmEvaluatedLesson? {
        
        return realm.object(ofType: RealmEvaluatedLesson.self, forPrimaryKey: lessonId)
    }
}
