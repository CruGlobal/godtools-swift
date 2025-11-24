//
//  MockRealmLanguage.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class MockRealmLanguage {
    
    static func createLanguage(language: LanguageCodeDomainModel, name: String, id: String = UUID().uuidString) -> RealmLanguage {
        
        let realmLanguage = RealmLanguage()
        realmLanguage.id = id
        realmLanguage.code = language.rawValue
        realmLanguage.name = name
        
        return realmLanguage
    }
}
