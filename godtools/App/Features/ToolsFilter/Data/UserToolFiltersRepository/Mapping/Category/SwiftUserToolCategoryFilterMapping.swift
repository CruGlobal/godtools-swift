//
//  SwiftUserToolCategoryFilterMapping.swift
//  godtools
//
//  Created by Levi Eggert on 4/25/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftUserToolCategoryFilterMapping: Mapping {
    
    func toDataModel(externalObject: UserToolCategoryFilterDataModel) -> UserToolCategoryFilterDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: SwiftUserToolCategoryFilter) -> UserToolCategoryFilterDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: UserToolCategoryFilterDataModel) -> SwiftUserToolCategoryFilter? {
        return SwiftUserToolCategoryFilter.createNewFrom(model: externalObject)
    }
}
