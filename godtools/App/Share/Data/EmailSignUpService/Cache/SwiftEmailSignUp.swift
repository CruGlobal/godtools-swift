//
//  SwiftEmailSignUp.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17.4, *)
typealias SwiftEmailSignUp = SwiftEmailSignUpV1.SwiftEmailSignUp

@available(iOS 17.4, *)
enum SwiftEmailSignUpV1 {
 
    @Model
    class SwiftEmailSignUp: IdentifiableSwiftDataObject {
        
        var firstName: String?
        var isRegistered: Bool = false
        var lastName: String?
        
        @Attribute(.unique) var email: String = ""
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
    }
}
