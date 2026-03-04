//
//  SwiftUserCounterMapping.swift
//  godtools
//
//  Created by Levi Eggert on 3/4/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftUserCounterMapping: Mapping {
    
    func toDataModel(externalObject: UserCounterCodable) -> UserCounterDataModel? {
        return UserCounterDataModel(interface: externalObject)
    }
    
    func toDataModel(persistObject: SwiftUserCounter) -> UserCounterDataModel? {
        return UserCounterDataModel(interface: persistObject)
    }
    
    func toPersistObject(externalObject: UserCounterCodable) -> SwiftUserCounter? {
        return SwiftUserCounter.createNewFrom(interface: externalObject)
    }
}
