//
//  SwiftUserAppLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
typealias SwiftUserAppLanguage = SwiftUserAppLanguageV1.SwiftUserAppLanguage

@available(iOS 17, *)
enum SwiftUserAppLanguageV1 {
 
    @available(iOS 17, *)
    @Model
    class SwiftUserAppLanguage: IdentifiableSwiftDataObject {
        
        var languageId: BCP47LanguageIdentifier = ""
        
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
    }
}
