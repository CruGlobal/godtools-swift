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
        return externalObject.toModel()
    }
    
    func toDataModel(persistObject: RealmUserCounter) -> UserCounterDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: UserCounterCodable) -> RealmUserCounter? {
        
        // TODO: Is there a way to check for an existing realm user counter to map against here? ~Levi
        
        assertionFailure("Not setup to persist external objects as it would overrite the local count and count.")
        return nil
    }
}
