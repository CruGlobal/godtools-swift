//
//  SwiftResourceDataModelMapping.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

@available(iOS 17, *)
class SwiftResourceDataModelMapping: RepositorySyncMapping {
    
    func toDataModel(externalObject: ResourceCodable) -> ResourceDataModel? {
        return ResourceDataModel(interface: externalObject)
    }
    
    func toDataModel(persistObject: SwiftResource) -> ResourceDataModel? {
        return ResourceDataModel(interface: persistObject)
    }
    
    func toPersistObject(externalObject: ResourceCodable) -> SwiftResource? {
        return SwiftResource.createNewFrom(interface: externalObject)
    }
}
