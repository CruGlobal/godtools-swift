//
//  RealmLessonCompletionCache.swift
//  godtools
//
//  Created by Rachael Skeath on 9/25/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmLessonCompletionCache {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        self.realmDatabase = realmDatabase
    }
    
    func getUserLessonCompletion(lessonId: String) -> LessonCompletionDataModel? {
        
        if let realmLessonCompletion = realmDatabase.openRealm().object(ofType: RealmLessonCompletion.self, forPrimaryKey: lessonId) {
            
            return LessonCompletionDataModel(realmLessonCompletion: realmLessonCompletion)
        } else {
            return nil
        }
    }
    
    func storeUserLessonCompletion(_ lessonCompletion: LessonCompletionDataModel) {
        
        let realm: Realm = realmDatabase.openRealm()
        
        let realmLessonCompletion = RealmLessonCompletion()
        realmLessonCompletion.lessonId = lessonCompletion.lessonId
        realmLessonCompletion.progress = lessonCompletion.progress
        
        do {
            
            try realm.write {
                realm.add(realmLessonCompletion, update: .modified)
            }
        }
        catch let error {
            print(error)
        }
    }
}
