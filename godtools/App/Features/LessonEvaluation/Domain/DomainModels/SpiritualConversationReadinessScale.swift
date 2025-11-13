//
//  SpiritualConversationReadinessScale.swift
//  godtools
//
//  Created by Levi Eggert on 4/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct SpiritualConversationReadinessScale {
    
    let minScale: LessonEvaluationScale
    let maxScale: LessonEvaluationScale
    let scale: LessonEvaluationScale
    
    static var emptyValue: SpiritualConversationReadinessScale {
        return SpiritualConversationReadinessScale(
            minScale: LessonEvaluationScale.emptyValue,
            maxScale: LessonEvaluationScale.emptyValue,
            scale: LessonEvaluationScale.emptyValue
        )
    }
}
