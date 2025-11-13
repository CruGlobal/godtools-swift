//
//  LessonEvaluationScale.swift
//  godtools
//
//  Created by Levi Eggert on 4/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct LessonEvaluationScale {
    
    let integerValue: Int
    let valueTranslatedInAppLanguage: String
    
    static var emptyValue: LessonEvaluationScale {
        return LessonEvaluationScale(integerValue: 0, valueTranslatedInAppLanguage: "")
    }
}
