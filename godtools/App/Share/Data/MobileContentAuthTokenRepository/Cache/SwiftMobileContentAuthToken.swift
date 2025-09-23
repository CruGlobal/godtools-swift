//
//  SwiftMobileContentAuthToken.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
class SwiftMobileContentAuthToken: IdentifiableSwiftDataObject {
    
    var expirationDate: Date?
    
    @Attribute(.unique) var id: String = ""
    @Attribute(.unique) var userId: String = ""
    
    init() {
        
    }
}
