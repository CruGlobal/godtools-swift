//
//  SpiritualConversationReadinessScale.swift
//  godtools
//
//  Created by Levi Eggert on 4/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct SpiritualConversationReadinessScaleDomainModel: Sendable {
    
    let minScale: LessonEvaluationScaleDomainModel
    let maxScale: LessonEvaluationScaleDomainModel
    let scale: LessonEvaluationScaleDomainModel
    
    static var emptyValue: SpiritualConversationReadinessScaleDomainModel {
        return SpiritualConversationReadinessScaleDomainModel(
            minScale: LessonEvaluationScaleDomainModel.emptyValue,
            maxScale: LessonEvaluationScaleDomainModel.emptyValue,
            scale: LessonEvaluationScaleDomainModel.emptyValue
        )
    }
}
