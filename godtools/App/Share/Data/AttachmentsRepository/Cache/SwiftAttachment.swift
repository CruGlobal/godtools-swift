//
//  SwiftAttachment.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftAttachment = SwiftAttachmentV1.SwiftAttachment

@available(iOS 17.4, *)
enum SwiftAttachmentV1 {
 
    @Model
    class SwiftAttachment: IdentifiableSwiftDataObject {
        
        var file: String = ""
        var fileFilename: String = ""
        var isZipped: Bool = false
        var resourceId: String?
        var sha256: String = ""
        var type: String = ""
        
        @Attribute(.unique) var id: String = ""
        
        @Relationship(deleteRule: .nullify) var resource: SwiftResource?
        
        init() {
            
        }
        
        func mapFrom(model: AttachmentDataModel) {
            file = model.file
            fileFilename = model.fileFilename
            id = model.id
            isZipped = model.isZipped
            sha256 = model.sha256
            type = model.type
        }
        
        static func createNewFrom(model: AttachmentDataModel) -> SwiftAttachment {
            let attachment = SwiftAttachment()
            attachment.mapFrom(model: model)
            return attachment
        }
        
        var resourceDataModel: ResourceDataModel? {
            
            guard let swiftResource = resource else {
                return nil
            }
            
            return swiftResource.toModel()
        }
    }
}

@available(iOS 17.4, *)
extension SwiftAttachment {
    
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
}
