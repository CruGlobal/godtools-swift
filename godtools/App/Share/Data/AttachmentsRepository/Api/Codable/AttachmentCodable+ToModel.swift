//
//  AttachmentCodable+ToModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/16/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

extension AttachmentCodable {
    
    func toModel() -> AttachmentDataModel {
        return AttachmentDataModel(
            id: id,
            file: file,
            fileFilename: fileFilename,
            isZipped: isZipped,
            sha256: sha256,
            type: type,
            resourceDataModel: resourceDataModel,
            storedAttachment: nil
        )
    }
    
    var resourceDataModel: ResourceDataModel? {
       
        guard let resource = resource else {
            return nil
        }
        
        return resource.toModel()
    }
}
