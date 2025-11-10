//
//  SwiftDownloadedLanguage.swift
//  godtools
//
//  Created by Rachael Skeath on 10/9/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17.4, *)
typealias SwiftDownloadedLanguage = SwiftDownloadedLanguageV1.SwiftDownloadedLanguage

@available(iOS 17.4, *)
enum SwiftDownloadedLanguageV1 {
    
    @Model
    class SwiftDownloadedLanguage: IdentifiableSwiftDataObject {
        
        var createdAt: Date = Date()
        var downloadComplete: Bool = false
        
        @Attribute(.unique) var id: String = ""
        @Attribute(.unique) var languageId: String = ""
        
        init() {
            
        }
    }
}
