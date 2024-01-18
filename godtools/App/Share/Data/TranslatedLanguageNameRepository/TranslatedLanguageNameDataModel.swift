//
//  TranslatedLanguageNameDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct TranslatedLanguageNameDataModel {
    
    let createdAt: Date
    let id: String
    let language: BCP47LanguageIdentifier
    let languageTranslation: BCP47LanguageIdentifier
    let translatedName: String
    let updatedAt: Date
    
    init(realmObject: RealmTranslatedLanguageName) {
        
        createdAt = realmObject.createdAt
        id = realmObject.id
        language = realmObject.language
        languageTranslation = realmObject.languageTranslation
        translatedName = realmObject.translatedName
        updatedAt = realmObject.updatedAt
    }
}
