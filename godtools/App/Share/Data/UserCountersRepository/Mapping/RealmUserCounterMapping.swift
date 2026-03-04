//
//  RealmUserCounterMapping.swift
//  godtools
//
//  Created by Levi Eggert on 3/4/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmUserCounterMapping: Mapping {
    
    func toDataModel(externalObject: UserCounterCodable) -> UserCounterDataModel? {
        return UserCounterDataModel(interface: externalObject)
    }
    
    func toDataModel(persistObject: RealmUserCounter) -> UserCounterDataModel? {
        return UserCounterDataModel(interface: persistObject)
    }
    
    func toPersistObject(externalObject: UserCounterCodable) -> RealmUserCounter? {
        return RealmUserCounter.createNewFrom(interface: externalObject)
    }
}
