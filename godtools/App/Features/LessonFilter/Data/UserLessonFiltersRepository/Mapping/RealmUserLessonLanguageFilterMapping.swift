//
//  RealmUserLessonLanguageFilterMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmUserLessonLanguageFilterMapping: Mapping {
    
    func toDataModel(externalObject: UserLessonLanguageFilterDataModel) -> UserLessonLanguageFilterDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: RealmUserLessonLanguageFilter) -> UserLessonLanguageFilterDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: UserLessonLanguageFilterDataModel) -> RealmUserLessonLanguageFilter? {
        return RealmUserLessonLanguageFilter.createNewFrom(model: externalObject)
    }
}
