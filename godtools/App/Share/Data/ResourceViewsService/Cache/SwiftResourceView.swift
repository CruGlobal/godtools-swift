//
//  SwiftResourceView.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17.4, *)
typealias SwiftResourceView = SwiftResourceViewV1.SwiftResourceView

@available(iOS 17.4, *)
enum SwiftResourceViewV1 {
 
    @Model
    class SwiftResourceView: IdentifiableSwiftDataObject {
        
        var quantity: Int = 0
        
        @Attribute(.unique) var id: String = ""
        @Attribute(.unique) var resourceId: String = ""
        
        init() {
            
        }
    }
}
