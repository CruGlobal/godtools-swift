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
            AppLanguageDataModel(languageCode: "ar", languageDirection: .rightToLeft, languageScriptCode: nil),
            AppLanguageDataModel(languageCode: "en", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageDataModel(languageCode: "es", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageDataModel(languageCode: "pt", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageDataModel(languageCode: "fr", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageDataModel(languageCode: "id", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageDataModel(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hans"),
            AppLanguageDataModel(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hant"),
            AppLanguageDataModel(languageCode: "hi", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageDataModel(languageCode: "ru", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageDataModel(languageCode: "vi", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageDataModel(languageCode: "lv", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageDataModel(languageCode: "bn", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageDataModel(languageCode: "ur", languageDirection: .rightToLeft, languageScriptCode: nil)
        ]
    }
    
    func getAppLanguages() -> [AppLanguageDataModel] {
        
        return appLanguages
    }
}
