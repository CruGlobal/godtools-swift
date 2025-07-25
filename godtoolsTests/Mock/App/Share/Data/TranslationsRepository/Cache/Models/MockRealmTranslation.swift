//
//  MockRealmTranslation.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class MockRealmTranslation {
    
    static func createTranslation(translatedName: String, id: String = UUID().uuidString) -> RealmTranslation {
        
        let realmTranslation = RealmTranslation()
        
        realmTranslation.id = id
        realmTranslation.translatedName = translatedName
        
        return realmTranslation
    }
}
