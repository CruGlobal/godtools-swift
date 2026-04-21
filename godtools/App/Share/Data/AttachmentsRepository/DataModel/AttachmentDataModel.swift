//
//  AttachmentDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct AttachmentDataModel: Sendable {
        
    let id: String
    let file: String
    let fileFilename: String
    let isZipped: Bool
    let sha256: String
    let type: String
    let resourceDataModel: ResourceDataModel?
    let storedAttachment: StoredAttachmentDataModel?
    
    func copy(storedAttachment: StoredAttachmentDataModel?) -> AttachmentDataModel {
        
        return AttachmentDataModel(
            id: id,
            file: file,
            fileFilename: fileFilename,
            isZipped: isZipped,
            sha256: sha256,
            type: type,
            resourceDataModel: resourceDataModel,
            storedAttachment: storedAttachment ?? self.storedAttachment
        )
    }
}
