//
//  AttachmentDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AttachmentDataModel {
        
    let file: String
    let fileFilename: String
    let id: String
    let isZipped: Bool
    let sha256: String
    let type: String
    let resourceDataModel: ResourceDataModel?
    let storedAttachment: StoredAttachmentDataModel?
    
    init(id: String, file: String, fileFilename: String, isZipped: Bool, sha256: String, type: String, resourceDataModel: ResourceDataModel?, storedAttachment: StoredAttachmentDataModel?) {
        
        self.id = id
        self.file = file
        self.fileFilename = fileFilename
        self.isZipped = isZipped
        self.sha256 = sha256
        self.type = type
        self.resourceDataModel = resourceDataModel
        self.storedAttachment = storedAttachment
    }
    
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
