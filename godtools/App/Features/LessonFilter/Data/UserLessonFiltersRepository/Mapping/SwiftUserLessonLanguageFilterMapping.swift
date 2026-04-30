//
//  SwiftUserLessonLanguageFilterMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftUserLessonLanguageFilterMapping: Mapping {
    
    func toDataModel(externalObject: UserLessonLanguageFilterDataModel) -> UserLessonLanguageFilterDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: SwiftUserLessonLanguageFilter) -> UserLessonLanguageFilterDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: UserLessonLanguageFilterDataModel) -> SwiftUserLessonLanguageFilter? {
        return SwiftUserLessonLanguageFilter.createNewFrom(model: externalObject)
    }
}
