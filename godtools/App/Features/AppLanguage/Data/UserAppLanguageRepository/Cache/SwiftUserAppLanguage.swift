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
@Model
class SwiftUserAppLanguage: IdentifiableSwiftDataObject {
    
    @Attribute(.unique) var id: String = ""
    var languageId: BCP47LanguageIdentifier = ""
    
    init() {
        
    }
}
