//
//  LessonEvaluationScale.swift
//  godtools
//
//  Created by Levi Eggert on 4/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct LessonEvaluationScaleDomainModel: Sendable {
    
    let integerValue: Int
    let valueTranslatedInAppLanguage: String
    
    static var emptyValue: LessonEvaluationScaleDomainModel {
        return LessonEvaluationScaleDomainModel(integerValue: 0, valueTranslatedInAppLanguage: "")
    }
}
