//
//  SwiftLessonEvaluationMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftLessonEvaluationMapping: Mapping {
    
    func toDataModel(externalObject: LessonEvaluationDataModel) -> LessonEvaluationDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: SwiftLessonEvaluation) -> LessonEvaluationDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: LessonEvaluationDataModel) -> SwiftLessonEvaluation? {
        return SwiftLessonEvaluation.createNewFrom(model: externalObject)
    }
}
