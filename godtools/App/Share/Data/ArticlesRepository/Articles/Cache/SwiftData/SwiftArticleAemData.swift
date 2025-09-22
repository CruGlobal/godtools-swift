//
//  SwiftArticleAemData.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
class SwiftArticleAemData: IdentifiableSwiftDataObject {
    
    var articleJcrContent: RealmArticleJcrContent?
    var webUrl: String = ""
    var webArchiveFilename: String = ""
    var updatedAt: Date = Date()
    
    @Attribute(.unique) var aemUri: String = ""
    @Attribute(.unique) var id: String = ""
    
    init() {
        
    }
}
