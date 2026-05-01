//
//  RealmLocalActivityCountMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmLocalActivityCountMapping: Mapping {
    
    func toDataModel(externalObject: LocalActivityCountDataModel) -> LocalActivityCountDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: RealmLocalActivityCount) -> LocalActivityCountDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: LocalActivityCountDataModel) -> RealmLocalActivityCount? {
        return RealmLocalActivityCount.createNewFrom(model: externalObject)
    }
}
