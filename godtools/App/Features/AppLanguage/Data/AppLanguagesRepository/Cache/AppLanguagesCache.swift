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
            AppLanguageDataModel(languageCode: "ar", languageDirection: .rightToLeft),
            AppLanguageDataModel(languageCode: "en", languageDirection: .leftToRight),
            AppLanguageDataModel(languageCode: "es", languageDirection: .leftToRight),
            AppLanguageDataModel(languageCode: "pt", languageDirection: .leftToRight),
            AppLanguageDataModel(languageCode: "fr", languageDirection: .leftToRight),
            AppLanguageDataModel(languageCode: "id", languageDirection: .leftToRight),
            AppLanguageDataModel(languageCode: "zh-Hans", languageDirection: .leftToRight),
            AppLanguageDataModel(languageCode: "zh-Hant", languageDirection: .leftToRight),
            AppLanguageDataModel(languageCode: "hi", languageDirection: .leftToRight),
            AppLanguageDataModel(languageCode: "ru", languageDirection: .leftToRight),
            AppLanguageDataModel(languageCode: "vi", languageDirection: .leftToRight),
            AppLanguageDataModel(languageCode: "lv", languageDirection: .leftToRight)
        ]
    }
    
    func getAppLanguages() -> [AppLanguageDataModel] {
        
        return appLanguages
    }
}
