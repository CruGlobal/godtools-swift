//
//  SwiftArticleJrcContent.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
class SwiftArticleJrcContent: IdentifiableSwiftDataObject {
    
    var aemUri: String = ""
    var canonical: String?
    var tags: [String] = Array<String>()
    var title: String?
    var uuid: String?
    
    @Attribute(.unique) var id: String = ""
    
    init() {
        
    }
}
