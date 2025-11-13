//
//  LessonEvaluationStrings.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct LessonEvaluationStrings {
    
    let title: String
    let wasThisHelpful: String
    let yesActionTitle: String
    let noActionTitle: String
    let shareFaithReadiness: String
    let sendFeedbackActionTitle: String
    
    static var emptyValue: LessonEvaluationStrings {
        return LessonEvaluationStrings(title: "", wasThisHelpful: "", yesActionTitle: "", noActionTitle: "", shareFaithReadiness: "", sendFeedbackActionTitle: "")
    }
}
