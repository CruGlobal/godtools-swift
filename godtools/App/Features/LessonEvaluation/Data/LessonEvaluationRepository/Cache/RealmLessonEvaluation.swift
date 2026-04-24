//
//  RealmLessonEvaluation.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmLessonEvaluation: Object, IdentifiableRealmObject {
    
    @objc dynamic var lastEvaluationAttempt: Date = Date()
    @objc dynamic var lessonAbbreviation: String = ""
    @objc dynamic var lessonEvaluated: Bool = false
    @objc dynamic var lessonId: String = ""
    @objc dynamic var numberOfEvaluationAttempts: Int = 0
    
    @objc dynamic var id: String {
        get {
            return lessonId
        }
        set {
            lessonId = newValue
        }
    }
    
    override static func primaryKey() -> String? {
        return "lessonId"
    }
}

extension RealmLessonEvaluation {
    
    func mapFrom(model: LessonEvaluationDataModel) {
        
        lessonId = model.lessonId
        id = model.id
        lastEvaluationAttempt = model.lastEvaluationAttempt
        lessonAbbreviation = model.lessonAbbreviation
        lessonEvaluated = model.lessonEvaluated
        numberOfEvaluationAttempts = model.numberOfEvaluationAttempts
    }
    
    static func createNewFrom(model: LessonEvaluationDataModel) -> RealmLessonEvaluation {
        
        let object = RealmLessonEvaluation()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> LessonEvaluationDataModel {
        return LessonEvaluationDataModel(
            id: id,
            lastEvaluationAttempt: lastEvaluationAttempt,
            lessonAbbreviation: lessonAbbreviation,
            lessonEvaluated: lessonEvaluated,
            lessonId: lessonId,
            numberOfEvaluationAttempts: numberOfEvaluationAttempts
        )
    }
}
