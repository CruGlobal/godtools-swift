//
//  RealmResourceMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmResourceMapping: Mapping {
    
    func toDataModel(externalObject: ResourceCodable) -> ResourceDataModel? {
        return externalObject.toModel()
    }
    
    func toDataModel(persistObject: RealmResource) -> ResourceDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: ResourceCodable) -> RealmResource? {
        return RealmResource.createNewFrom(model: externalObject.toModel())
    }
}
