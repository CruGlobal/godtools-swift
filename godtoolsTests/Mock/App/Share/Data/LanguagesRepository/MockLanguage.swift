//
//  MockLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 11/25/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class MockLanguage {
    
    var code: BCP47LanguageIdentifier = ""
    var directionString: String = ""
    var id: String = ""
    var name: String = ""
    var type: String = ""
    var forceLanguageName: Bool = false
    
    static func createLanguage(language: LanguageCodeDomainModel, name: String, id: String = UUID().uuidString) -> MockLanguage {
        
        let mockLanguage = MockLanguage()
        mockLanguage.id = id
        mockLanguage.code = language.rawValue
        mockLanguage.name = name
        
        return mockLanguage
    }
}

extension MockLanguage {
    
    func toModel() -> LanguageDataModel {
        return LanguageDataModel(code: code, directionString: directionString, id: id, name: name, type: type, forceLanguageName: forceLanguageName)
    }
}
