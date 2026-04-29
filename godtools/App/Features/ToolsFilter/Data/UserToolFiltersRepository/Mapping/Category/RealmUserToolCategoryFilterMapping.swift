//
//  RealmUserToolCategoryFilterMapping.swift
//  godtools
//
//  Created by Levi Eggert on 4/25/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmUserToolCategoryFilterMapping: Mapping {
    
    func toDataModel(externalObject: UserToolCategoryFilterDataModel) -> UserToolCategoryFilterDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: RealmUserToolCategoryFilter) -> UserToolCategoryFilterDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: UserToolCategoryFilterDataModel) -> RealmUserToolCategoryFilter? {
        return RealmUserToolCategoryFilter.createNewFrom(model: externalObject)
    }
}
