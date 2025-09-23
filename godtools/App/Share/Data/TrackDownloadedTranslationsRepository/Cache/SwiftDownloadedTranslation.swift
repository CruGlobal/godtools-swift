//
//  SwiftDownloadedTranslation.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
class SwiftDownloadedTranslation: IdentifiableSwiftDataObject {
    
    var languageId: String = ""
    var manifestAndRelatedFilesPersistedToDevice: Bool = false
    var resourceId: String = ""
    var version: Int = -1
    
    @Attribute(.unique) var id: String = ""
    @Attribute(.unique) var translationId: String = ""
    
    init() {
        
    }
}
