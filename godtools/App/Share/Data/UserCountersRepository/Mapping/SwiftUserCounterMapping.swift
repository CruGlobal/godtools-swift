//
//  SwiftUserCounterMapping.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftUserCounterMapping: Mapping {
    
    func toDataModel(externalObject: UserCounterDecodable) -> UserCounterDataModel? {
        return UserCounterDataModel(interface: externalObject)
    }
    
    func toDataModel(persistObject: SwiftUserCounter) -> UserCounterDataModel? {
        return UserCounterDataModel(interface: persistObject)
    }
    
    func toPersistObject(externalObject: UserCounterDecodable) -> SwiftUserCounter? {
        return SwiftUserCounter.createNewFrom(interface: externalObject)
    }
}
