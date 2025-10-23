//
//  SwiftAttachment.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
typealias SwiftAttachment = SwiftAttachmentV1.SwiftAttachment

@available(iOS 17, *)
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
    }
}
