//
//  SwiftLessonEvaluation.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftLessonEvaluation = SwiftLessonEvaluationV1.SwiftLessonEvaluation

@available(iOS 17.4, *)
enum SwiftLessonEvaluationV1 {
 
    @Model
    class SwiftLessonEvaluation: IdentifiableSwiftDataObject {
        
        var lastEvaluationAttempt: Date = Date()
        var lessonAbbreviation: String = ""
        var lessonEvaluated: Bool = false
        var numberOfEvaluationAttempts: Int = 0
        
        @Attribute(.unique) var id: String = ""
        @Attribute(.unique) var lessonId: String = ""
        
        init() {
            
        }
    }
}

@available(iOS 17.4, *)
extension SwiftLessonEvaluation {
    
    func mapFrom(model: LessonEvaluationDataModel) {
        
        id = model.id
        lessonId = model.lessonId
        lastEvaluationAttempt = model.lastEvaluationAttempt
        lessonAbbreviation = model.lessonAbbreviation
        lessonEvaluated = model.lessonEvaluated
        numberOfEvaluationAttempts = model.numberOfEvaluationAttempts
    }
    
    static func createNewFrom(model: LessonEvaluationDataModel) -> SwiftLessonEvaluation {
        
        let object = SwiftLessonEvaluation()
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
