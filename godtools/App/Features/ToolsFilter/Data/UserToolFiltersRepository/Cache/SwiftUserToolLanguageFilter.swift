//
//  SwiftUserToolLanguageFilter.swift
//  godtools
//
//  Created by Rachael Skeath on 10/9/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftUserToolLanguageFilter = SwiftUserToolLanguageFilterV1.SwiftUserToolLanguageFilter

@available(iOS 17.4, *)
enum SwiftUserToolLanguageFilterV1 {
    
    @Model
    class SwiftUserToolLanguageFilter: IdentifiableSwiftDataObject {
        
        static let filterId = "userToolLanguageFilter"
        
        var createdAt: Date = Date()
        var languageId: String = ""
        
        @Attribute(.unique) var id: String = ""
        @Attribute(.unique) var filterId: String = SwiftUserToolLanguageFilter.filterId
        
        init() {
            
        }
    }
}
