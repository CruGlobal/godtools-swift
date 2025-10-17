//
//  SwiftAppLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
typealias SwiftAppLanguage = SwiftAppLanguageV1.SwiftAppLanguage

@available(iOS 17, *)
enum SwiftAppLanguageV1 {
 
    @Model
    class SwiftAppLanguage: IdentifiableSwiftDataObject {
        
        var languageCode: String = ""
        var languageDirection: SwiftAppLanguageDirection = SwiftAppLanguageDirection.leftToRight
        var languageId: String = ""
        var languageScriptCode: String?
        
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
    }
}
