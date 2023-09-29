//
//  AppLanguagesRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class AppLanguagesRepository {
    
    init() {
        
    }
    
    func getLanguagesPublisher() -> AnyPublisher<[AppLanguageDataModel], Never> {
        
        /*
        let appLanguages: [AppLanguageDataModel] = [
            AppLanguageDataModel(languageCode: "en", languageDirection: .leftToRight),
            AppLanguageDataModel(languageCode: "es", languageDirection: .leftToRight),
            AppLanguageDataModel(languageCode: "pt", languageDirection: .leftToRight),
            AppLanguageDataModel(languageCode: "fr", languageDirection: .leftToRight),
            AppLanguageDataModel(languageCode: "id", languageDirection: .leftToRight),
            AppLanguageDataModel(languageCode: "zh-Hans", languageDirection: .leftToRight),
            AppLanguageDataModel(languageCode: "zh-Hant", languageDirection: .leftToRight),
            AppLanguageDataModel(languageCode: "hi", languageDirection: .leftToRight),
            AppLanguageDataModel(languageCode: "ar", languageDirection: .rightToLeft),
            AppLanguageDataModel(languageCode: "ru", languageDirection: .leftToRight),
            AppLanguageDataModel(languageCode: "vi", languageDirection: .leftToRight),
            AppLanguageDataModel(languageCode: "lv", languageDirection: .leftToRight)
        ]*/
        
        let appLanguages: [AppLanguageDataModel] = [
            AppLanguageDataModel(languageCode: "en", languageDirection: .leftToRight),
            AppLanguageDataModel(languageCode: "ar", languageDirection: .rightToLeft)
        ]
        
        return Just(appLanguages)
            .eraseToAnyPublisher()
    }

    func getLanguagePublisher(languageCode: String) -> AnyPublisher<AppLanguageDataModel?, Never> {
        
        return getLanguagesPublisher()
            .flatMap({ (languages: [AppLanguageDataModel]) -> AnyPublisher<AppLanguageDataModel?, Never> in
                
                let language: AppLanguageDataModel? = languages.filter({
                    $0.languageCode.lowercased() == languageCode.lowercased()
                }).first
                
                return Just(language)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
