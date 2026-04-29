//
//  SwiftUserLessonProgressMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftUserLessonProgressMapping: Mapping {
    
    func toDataModel(externalObject: UserLessonProgressDataModel) -> UserLessonProgressDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: SwiftUserLessonProgress) -> UserLessonProgressDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: UserLessonProgressDataModel) -> SwiftUserLessonProgress? {
        return SwiftUserLessonProgress.createNewFrom(model: externalObject)
    }
}
