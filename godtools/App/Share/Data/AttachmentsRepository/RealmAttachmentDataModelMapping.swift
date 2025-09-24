//
//  RealmAttachmentDataModelMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class RealmAttachmentDataModelMapping: RepositorySyncMapping {
    
    init() {
        
    }
    
    func toDataModel(externalObject: AttachmentCodable) -> AttachmentDataModel? {
        return AttachmentDataModel(interface: externalObject, storedAttachment: nil)
    }
    
    func toDataModel(persistObject: RealmAttachment) -> AttachmentDataModel? {
        return AttachmentDataModel(interface: persistObject, storedAttachment: nil)
    }
    
    func toPersistObject(externalObject: AttachmentCodable) -> RealmAttachment? {
        return RealmAttachment.createNewFrom(interface: externalObject)
    }
}
