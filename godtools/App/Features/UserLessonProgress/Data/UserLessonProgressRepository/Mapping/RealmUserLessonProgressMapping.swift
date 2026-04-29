//
//  RealmUserLessonProgressMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmUserLessonProgressMapping: Mapping {
    
    func toDataModel(externalObject: UserLessonProgressDataModel) -> UserLessonProgressDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: RealmUserLessonProgress) -> UserLessonProgressDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: UserLessonProgressDataModel) -> RealmUserLessonProgress? {
        return RealmUserLessonProgress.createNewFrom(model: externalObject)
    }
}
