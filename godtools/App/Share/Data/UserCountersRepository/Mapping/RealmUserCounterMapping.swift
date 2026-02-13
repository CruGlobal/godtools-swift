//
//  RealmUserCounterMapping.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmUserCounterMapping: Mapping {
    
    func toDataModel(externalObject: UserCounterDecodable) -> UserCounterDataModel? {
        return UserCounterDataModel(interface: externalObject)
    }
    
    func toDataModel(persistObject: RealmUserCounter) -> UserCounterDataModel? {
        return UserCounterDataModel(interface: persistObject)
    }
    
    func toPersistObject(externalObject: UserCounterDecodable) -> RealmUserCounter? {
        return RealmUserCounter.createNewFrom(interface: externalObject)
    }
}
