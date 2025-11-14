//
//  ScaleValue.swift
//  godtools
//
//  Created by Levi Eggert on 4/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct ScaleValue {
    
    let integerValue: Int
    let displayValue: String
    
    init(integerValue: Int, displayValue: String) {
        
        self.integerValue = integerValue
        self.displayValue = displayValue
    }
    
    init(lessonEvaluationScale: LessonEvaluationScaleDomainModel) {
        
        integerValue = lessonEvaluationScale.integerValue
        displayValue = lessonEvaluationScale.valueTranslatedInAppLanguage
    }
}
