//
//  RealmTranslatedLanguageName.swift
//  godtools
//
//  Created by Levi Eggert on 1/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmTranslatedLanguageName: Object {
    
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var id: String = ""
    @objc dynamic var language: BCP47LanguageIdentifier = ""
    @objc dynamic var languageTranslation: BCP47LanguageIdentifier = ""
    @objc dynamic var translatedName: String = ""
    @objc dynamic var updatedAt: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
