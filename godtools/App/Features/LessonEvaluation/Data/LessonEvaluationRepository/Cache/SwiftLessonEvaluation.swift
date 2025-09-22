//
//  SwiftLessonEvaluation.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
class SwiftLessonEvaluation: IdentifiableSwiftDataObject {
    
    @Attribute(.unique) var id: String = ""
    var lastEvaluationAttempt: Date = Date()
    var lessonAbbreviation: String = ""
    var lessonEvaluated: Bool = false
    @Attribute(.unique) var lessonId: String = ""
    var numberOfEvaluationAttempts: Int = 0
    
    init() {
        
    }
}
