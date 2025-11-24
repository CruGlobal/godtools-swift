//
//  SwiftAttachment.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17.4, *)
typealias SwiftAttachment = SwiftAttachmentV1.SwiftAttachment

@available(iOS 17.4, *)
enum SwiftAttachmentV1 {
 
    @Model
    class SwiftAttachment: IdentifiableSwiftDataObject, AttachmentDataModelInterface {
        
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
        
        func mapFrom(interface: AttachmentDataModelInterface) {
            file = interface.file
            fileFilename = interface.fileFilename
            id = interface.id
            isZipped = interface.isZipped
            sha256 = interface.sha256
            type = interface.type
        }
        
        static func createNewFrom(interface: AttachmentDataModelInterface) -> SwiftAttachment {
            let attachment = SwiftAttachment()
            attachment.mapFrom(interface: interface)
            return attachment
        }
        
        var resourceDataModel: ResourceDataModel? {
            
            guard let swiftResource = resource else {
                return nil
            }
            
            return ResourceDataModel(interface: swiftResource)
        }
    }
}
