//
//  SwiftUserToolCategoryFilter.swift
//  godtools
//
//  Created by Rachael Skeath on 10/9/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
typealias SwiftUserToolCategoryFilter = SwiftUserToolCategoryFilterV1.SwiftUserToolCategoryFilter

@available(iOS 17, *)
enum SwiftUserToolCategoryFilterV1 {
    
    @Model
    class SwiftUserToolCategoryFilter: IdentifiableSwiftDataObject {
        
        static let filterId = "userToolCategoryFilter"
        
        @objc dynamic var createdAt: Date = Date()
        @objc dynamic var categoryId: String = ""
        
        @Attribute(.unique) var id: String = ""
        @Attribute(.unique) var filterId: String = SwiftUserToolCategoryFilter.filterId
        
        init() {
            
        }
    }
}
