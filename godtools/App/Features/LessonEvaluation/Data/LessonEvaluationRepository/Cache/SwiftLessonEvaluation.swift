//
//  SwiftLessonEvaluation.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

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
