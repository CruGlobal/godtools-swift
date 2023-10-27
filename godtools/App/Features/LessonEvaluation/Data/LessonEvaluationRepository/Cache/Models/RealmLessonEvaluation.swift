//
//  RealmLessonEvaluation.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmLessonEvaluation: Object {
    
    @objc dynamic var lastEvaluationAttempt: Date = Date()
    @objc dynamic var lessonAbbreviation: String = ""
    @objc dynamic var lessonEvaluated: Bool = false
    @objc dynamic var lessonId: String = ""
    @objc dynamic var numberOfEvaluationAttempts: Int = 0
    
    override static func primaryKey() -> String? {
        return "lessonId"
    }
    
    func mapFrom(model: LessonEvaluationDataModel, ignorePrimaryKey: Bool) {
        
        if !ignorePrimaryKey {
            lessonId = model.lessonId
        }
        
        lastEvaluationAttempt = model.lastEvaluationAttempt
        lessonAbbreviation = model.lessonAbbreviation
        lessonEvaluated = model.lessonEvaluated
        numberOfEvaluationAttempts = model.numberOfEvaluationAttempts
    }
}
