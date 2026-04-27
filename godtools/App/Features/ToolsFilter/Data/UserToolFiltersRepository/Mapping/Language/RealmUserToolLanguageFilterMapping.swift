//
//  RealmUserToolLanguageFilterMapping.swift
//  godtools
//
//  Created by Levi Eggert on 4/25/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmUserToolLanguageFilterMapping: Mapping {
    
    func toDataModel(externalObject: UserToolLanguageFilterDataModel) -> UserToolLanguageFilterDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: RealmUserToolLanguageFilter) -> UserToolLanguageFilterDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: UserToolLanguageFilterDataModel) -> RealmUserToolLanguageFilter? {
        return RealmUserToolLanguageFilter.createNewFrom(model: externalObject)
    }
}
