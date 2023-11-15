//
//  AppLanguagesCache.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class AppLanguagesCache {
    
    private let appLanguages: [AppLanguageDataModel]
    
    init() {
        
        appLanguages = [
            AppLanguageDataModel(languageId: "ar", languageDirection: .rightToLeft),
            AppLanguageDataModel(languageId: "en", languageDirection: .leftToRight),
            AppLanguageDataModel(languageId: "es", languageDirection: .leftToRight),
            AppLanguageDataModel(languageId: "pt", languageDirection: .leftToRight),
            AppLanguageDataModel(languageId: "fr", languageDirection: .leftToRight),
            AppLanguageDataModel(languageId: "id", languageDirection: .leftToRight),
            AppLanguageDataModel(languageId: "zh-Hans", languageDirection: .leftToRight),
            AppLanguageDataModel(languageId: "zh-Hant", languageDirection: .leftToRight),
            AppLanguageDataModel(languageId: "hi", languageDirection: .leftToRight),
            AppLanguageDataModel(languageId: "ru", languageDirection: .leftToRight),
            AppLanguageDataModel(languageId: "vi", languageDirection: .leftToRight),
            AppLanguageDataModel(languageId: "lv", languageDirection: .leftToRight)
        ]
    }
    
    func getAppLanguages() -> [AppLanguageDataModel] {
        
        return appLanguages
    }
}
