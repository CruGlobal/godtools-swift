//
//  FakeRealmTranslation.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class FakeRealmTranslation {
    
    static func createTranslation(translatedName: String, id: String = UUID().uuidString, version: Int = -1) -> RealmTranslation {
        
        let realmTranslation = RealmTranslation()
        
        realmTranslation.id = id
        realmTranslation.translatedName = translatedName
        realmTranslation.version = version
        
        return realmTranslation
    }
}
