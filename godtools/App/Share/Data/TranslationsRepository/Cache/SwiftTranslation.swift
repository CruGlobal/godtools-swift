//
//  SwiftTranslation.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
class SwiftTranslation: IdentifiableSwiftDataObject {
    
    var isPublished: Bool = false
    var manifestName: String = ""
    var toolDetailsBibleReferences: String = ""
    var toolDetailsConversationStarters: String = ""
    var toolDetailsOutline: String = ""
    var translatedDescription: String = ""
    var translatedName: String = ""
    var translatedTagline: String = ""
    var type: String = ""
    var version: Int = -1
    
    @Attribute(.unique) var id: String = ""
    
    @Relationship(deleteRule: .nullify) var resource: SwiftResource?
    @Relationship(deleteRule: .nullify) var language: SwiftLanguage?
    
    init() {
        
    }
}
