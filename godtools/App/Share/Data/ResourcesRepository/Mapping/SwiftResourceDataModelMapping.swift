//
//  SwiftResourceDataModelMapping.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftResourceDataModelMapping: Mapping {
    
    func toDataModel(externalObject: ResourceCodable) -> ResourceDataModel? {
        return externalObject.toModel()
    }
    
    func toDataModel(persistObject: SwiftResource) -> ResourceDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: ResourceCodable) -> SwiftResource? {
        return SwiftResource.createNewFrom(model: externalObject.toModel())
    }
}
