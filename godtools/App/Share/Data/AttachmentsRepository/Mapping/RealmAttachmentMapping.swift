//
//  RealmAttachmentMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmAttachmentMapping: Mapping {
    
    init() {
        
    }
    
    func toDataModel(externalObject: AttachmentCodable) -> AttachmentDataModel? {
        return externalObject.toModel()
    }
    
    func toDataModel(persistObject: RealmAttachment) -> AttachmentDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: AttachmentCodable) -> RealmAttachment? {
        return RealmAttachment.createNewFrom(model: externalObject.toModel())
    }
}
