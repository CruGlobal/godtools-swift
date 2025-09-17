//
//  AttachmentsDataModelMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class AttachmentsDataModelMapping: RepositorySyncMapping<AttachmentDataModel, AttachmentCodable, RealmAttachment> {
    
    override func toDataModel(externalObject: AttachmentCodable) -> AttachmentDataModel? {
        return AttachmentDataModel(interface: externalObject, storedAttachment: nil)
    }
    
    override func toDataModel(persistObject: RealmAttachment) -> AttachmentDataModel? {
        return AttachmentDataModel(interface: persistObject, storedAttachment: nil)
    }
    
    override func toPersistObject(externalObject: AttachmentCodable) -> RealmAttachment? {
        return RealmAttachment.createNewFrom(interface: externalObject)
    }
}
