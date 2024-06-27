//
//  AppLanguagesApi.swift
//  godtools
//
//  Created by Levi Eggert on 5/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class AppLanguagesApi {
    
    init() {
        
    }
    
    func getAppLanguagesPublisher() -> AnyPublisher<[AppLanguageCodable], Error> {
        
        let allAppLanguages: [AppLanguageCodable] = [
            AppLanguageCodable(languageCode: "ar", languageDirection: .rightToLeft, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "en", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "es", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "pt", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "fr", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "id", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hans"),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hant"),
            AppLanguageCodable(languageCode: "hi", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "ru", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "vi", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "lv", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "bn", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "ur", languageDirection: .rightToLeft, languageScriptCode: nil)
        ]
        
        return Just(allAppLanguages).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
