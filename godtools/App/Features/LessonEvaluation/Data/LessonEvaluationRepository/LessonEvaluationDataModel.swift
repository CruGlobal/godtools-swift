//
//  LessonEvaluationDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

struct LessonEvaluationDataModel: Sendable {
    
    let id: String
    let lastEvaluationAttempt: Date
    let lessonAbbreviation: String
    let lessonEvaluated: Bool
    let lessonId: String
    let numberOfEvaluationAttempts: Int
}
