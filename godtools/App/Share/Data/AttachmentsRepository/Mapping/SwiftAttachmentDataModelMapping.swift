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
        return externalObject.toModel()
    }
    
    func toDataModel(persistObject: SwiftAttachment) -> AttachmentDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: AttachmentCodable) -> SwiftAttachment? {
        return SwiftAttachment.createNewFrom(model: externalObject.toModel())
    }
}
