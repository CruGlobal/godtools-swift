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
        
        return realmDatabase
            .observeCollectionChangesPublisher(objectClass: RealmUserLessonProgress.self, prepend: true)
            .eraseToAnyPublisher()
    }
    
    func getUserLessonProgress(lessonId: String) -> UserLessonProgressDataModel? {
        
        if let realmLessonProgress: RealmUserLessonProgress = realmDatabase.readObject(primaryKey: lessonId) {
            
            return UserLessonProgressDataModel(realmUserLessonProgress: realmLessonProgress)
        } else {
            return nil
        }
    }
    
    func storeUserLessonProgress(_ lessonProgress: UserLessonProgressDataModel) -> AnyPublisher<UserLessonProgressDataModel, Error> {
        
        return realmDatabase.writeObjectsPublisher(updatePolicy: .modified) { realm in
            
            let realmLessonProgress = RealmUserLessonProgress()
            realmLessonProgress.lessonId = lessonProgress.lessonId
            realmLessonProgress.lastViewedPageId = lessonProgress.lastViewedPageId
            realmLessonProgress.progress = lessonProgress.progress
            
            return [realmLessonProgress]
            
        } mapInBackgroundClosure: { (objects: [RealmUserLessonProgress]) in
            
            objects.map {
                UserLessonProgressDataModel(realmUserLessonProgress: $0)
            }
        }
        .map { _ in
            return lessonProgress
        }
        .eraseToAnyPublisher()
    }
}
