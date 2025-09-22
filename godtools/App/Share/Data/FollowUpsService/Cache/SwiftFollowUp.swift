//
//  SwiftFollowUp.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
class SwiftFollowUp: IdentifiableSwiftDataObject {
    
    var email: String = ""
    var destinationId: Int = -1
    var languageId: Int = -1
    var name: String = ""
    
    @Attribute(.unique) var id: String = ""
    
    init() {
        
    }
}
