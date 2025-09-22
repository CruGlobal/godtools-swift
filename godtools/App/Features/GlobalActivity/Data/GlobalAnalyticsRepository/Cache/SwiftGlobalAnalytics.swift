//
//  SwiftGlobalAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
class SwiftGlobalAnalytics: IdentifiableSwiftDataObject {
    
    var countries: Int = 0
    var createdAt: Date = Date()
    var gospelPresentations: Int = 0
    var launches: Int = 0
    var type: String = ""
    var users: Int = 0
    
    @Attribute(.unique) var id: String = ""
    
    init() {
        
    }
}
