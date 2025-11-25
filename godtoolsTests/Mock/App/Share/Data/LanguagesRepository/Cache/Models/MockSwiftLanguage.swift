//
//  MockSwiftLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 11/25/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
@testable import godtools

@available(iOS 17.4, *)
class MockSwiftLanguage {
    
    static func createLanguage(language: LanguageCodeDomainModel, name: String, id: String = UUID().uuidString) -> SwiftLanguage {
        
        let realmLanguage = SwiftLanguage()
        realmLanguage.id = id
        realmLanguage.code = language.rawValue
        realmLanguage.name = name
        
        return realmLanguage
    }
}
