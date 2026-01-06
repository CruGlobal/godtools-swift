//
//  SwiftUserLessonLanguageFilter.swift
//  godtools
//
//  Created by Rachael Skeath on 10/9/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftUserLessonLanguageFilter = SwiftUserLessonLanguageFilterV1.SwiftUserLessonLanguageFilter

@available(iOS 17.4, *)
enum SwiftUserLessonLanguageFilterV1 {
    
    @Model
    class SwiftUserLessonLanguageFilter: IdentifiableSwiftDataObject {
        
        var createdAt: Date = Date()
        var languageId: String = ""
        
        @Attribute(.unique) var id: String = ""
        @Attribute(.unique) var filterId: String = ""
        
        init() {
            
        }
    }
}
