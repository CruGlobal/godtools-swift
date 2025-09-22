//
//  SwiftEmailSignUp.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
class SwiftEmailSignUp: IdentifiableSwiftDataObject {
    
    @Attribute(.unique) var email: String = ""
    var firstName: String?
    @Attribute(.unique) var id: String = ""
    var isRegistered: Bool = false
    var lastName: String?
    
    init() {
        
    }
}
