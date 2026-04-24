//
//  RealmLessonEvaluationMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmLessonEvaluationMapping: Mapping {
    
    func toDataModel(externalObject: LessonEvaluationDataModel) -> LessonEvaluationDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: RealmLessonEvaluation) -> LessonEvaluationDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: LessonEvaluationDataModel) -> RealmLessonEvaluation? {
        return RealmLessonEvaluation.createNewFrom(model: externalObject)
    }
}
