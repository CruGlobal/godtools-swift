//
//  RealmUserLessonProgress.swift
//  godtools
//
//  Created by Rachael Skeath on 9/25/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmUserLessonProgress: Object, IdentifiableRealmObject {
    
    @Persisted var id: String = ""
    @Persisted var lessonId: String = ""
    @Persisted var lastViewedPageId: String = ""
    @Persisted var progress: Double = 0.0
    
    override class func primaryKey() -> String? {
        return "lessonId"
    }
}

extension RealmUserLessonProgress {
    
    func mapFrom(model: UserLessonProgressDataModel) {
        
        id = model.id
        lessonId = model.lessonId
        lastViewedPageId = model.lastViewedPageId
        progress = model.progress
    }
    
    static func createNewFrom(model: UserLessonProgressDataModel) -> RealmUserLessonProgress {
        
        let object = RealmUserLessonProgress()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> UserLessonProgressDataModel {
        return UserLessonProgressDataModel(
            id: id,
            lessonId: lessonId,
            lastViewedPageId: lastViewedPageId,
            progress: progress
        )
    }
}
