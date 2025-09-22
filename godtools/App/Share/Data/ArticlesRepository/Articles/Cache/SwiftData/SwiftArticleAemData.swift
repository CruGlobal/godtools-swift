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
    
    @Attribute(.unique) var aemUri: String = ""
    var articleJcrContent: RealmArticleJcrContent?
    @Attribute(.unique) var id: String = ""
    var webUrl: String = ""
    var webArchiveFilename: String = ""
    var updatedAt: Date = Date()
    
    init() {
        
    }
}
