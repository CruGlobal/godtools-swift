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
        return externalObject.toModel()
    }
    
    func toDataModel(persistObject: SwiftUserCounter) -> UserCounterDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: UserCounterCodable) -> SwiftUserCounter? {
        return SwiftUserCounter.createNewFrom(model: externalObject.toModel())
    }
}
