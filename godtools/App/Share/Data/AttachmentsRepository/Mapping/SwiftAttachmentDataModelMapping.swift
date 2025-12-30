//
//  SwiftAttachmentDataModelMapping.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftAttachmentDataModelMapping: Mapping {
    
    func toDataModel(externalObject: AttachmentCodable) -> AttachmentDataModel? {
        return AttachmentDataModel(interface: externalObject, storedAttachment: nil)
    }
    
    func toDataModel(persistObject: SwiftAttachment) -> AttachmentDataModel? {
        return AttachmentDataModel(interface: persistObject, storedAttachment: nil)
    }
    
    func toPersistObject(externalObject: AttachmentCodable) -> SwiftAttachment? {
        return SwiftAttachment.createNewFrom(interface: externalObject)
    }
}
