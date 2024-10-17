//
//  RealmUserLessonProgressCache.swift
//  godtools
//
//  Created by Rachael Skeath on 9/25/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmUserLessonProgressCache {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        self.realmDatabase = realmDatabase
    }
    
    func getUserLessonProgressChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return realmDatabase.openRealm()
            .objects(RealmUserLessonProgress.self)
            .objectWillChange
            .prepend(Void())
            .eraseToAnyPublisher()
    }
    
    func getUserLessonProgress(lessonId: String) -> UserLessonProgressDataModel? {
        
        if let realmLessonProgress = realmDatabase.openRealm().object(ofType: RealmUserLessonProgress.self, forPrimaryKey: lessonId) {
            
            return UserLessonProgressDataModel(realmUserLessonProgress: realmLessonProgress)
        } else {
            return nil
        }
    }
    
    func storeUserLessonProgress(_ lessonProgress: UserLessonProgressDataModel) {
        
        let realm: Realm = realmDatabase.openRealm()
        
        let realmLessonProgress = RealmUserLessonProgress()
        realmLessonProgress.lessonId = lessonProgress.lessonId
        realmLessonProgress.lastViewedPageId = lessonProgress.lastViewedPageId
        realmLessonProgress.progress = lessonProgress.progress
        
        do {
            
            try realm.write {
                realm.add(realmLessonProgress, update: .modified)
            }
        }
        catch let error {
            print(error)
        }
    }
}
