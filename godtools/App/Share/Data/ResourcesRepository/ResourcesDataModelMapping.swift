//
//  ResourcesDataModelMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class ResourcesDataModelMapping: RealmRepositorySyncMapping<ResourceDataModel, ResourceCodable, RealmResource> {
    
    override func toDataModel(externalObject: ResourceCodable) -> ResourceDataModel? {
        return ResourceDataModel(interface: externalObject)
    }
    
    override func toDataModel(persistObject: RealmResource) -> ResourceDataModel? {
        return ResourceDataModel(interface: persistObject)
    }
    
    override func toRealmObject(externalObject: ResourceCodable) -> RealmResource? {
        return RealmResource.createNewFrom(interface: externalObject)
    }
}
