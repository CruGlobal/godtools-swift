//
//  SwiftCategoryArticle.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
class SwiftCategoryArticle: IdentifiableSwiftDataObject {
    
    var aemTag: String = ""
    var aemUris: [String] = Array()
    var categoryId: String = ""
    var languageCode: String = ""
    
    @Attribute(.unique) var id: String = ""
    @Attribute(.unique) var uuid: String = ""
    
    init() {
        
    }
}
