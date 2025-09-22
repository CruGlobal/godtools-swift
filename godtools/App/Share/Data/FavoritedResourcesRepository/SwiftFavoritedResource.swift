//
//  SwiftFavoritedResource.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
class SwiftFavoritedResource: IdentifiableSwiftDataObject {
    
    var createdAt: Date = Date()
    var position: Int = 0
    
    @Attribute(.unique) var id: String = ""
    @Attribute(.unique) var resourceId: String = ""
    
    init() {
        
    }
}
