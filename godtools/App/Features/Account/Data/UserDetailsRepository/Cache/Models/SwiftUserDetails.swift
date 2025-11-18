//
//  SwiftUserDetails.swift
//  godtools
//
//  Created by Rachael Skeath on 10/9/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17.4, *)
typealias SwiftUserDetails = SwiftUserDetailsV1.SwiftUserDetails

@available(iOS 17.4, *)
enum SwiftUserDetailsV1 {
    
    @Model
    class SwiftUserDetails: IdentifiableSwiftDataObject {
        
        var createdAt: Date?
        var familyName: String?
        var givenName: String?
        var name: String?
        var ssoGuid: String?
        
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
    }
}
