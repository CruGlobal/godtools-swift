//
//  TranslatedLanguageNameRepositorySync.swift
//  godtools
//
//  Created by Levi Eggert on 1/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class TranslatedLanguageNameRepositorySync {
    
    private let languagesRepository: LanguagesRepository
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    private let cache: RealmTranslatedLanguageNameCache
    
    init(languagesRepository: LanguagesRepository, getTranslatedLanguageName: GetTranslatedLanguageName, cache: RealmTranslatedLanguageNameCache) {
        
        self.languagesRepository = languagesRepository
        self.getTranslatedLanguageName = getTranslatedLanguageName
        self.cache = cache
    }
    
    func syncTranslatedLanguageNamesPublisher(language: BCP47LanguageIdentifier) -> AnyPublisher<Void, Never> {
        
        return languagesRepository.getLanguagesChanged()
            .flatMap({ (languagesChanged: Void) -> AnyPublisher<Void, Never> in

                let languages: [LanguageModel] = self.languagesRepository.getLanguages()
                
                for languageModel in languages {
                    
                    let languageNameTranslatedInLanguage: String = self.getTranslatedLanguageName.getLanguageName(language: languageModel, translatedInLanguage: language)
                    let languageNameTranslatedInOwnLanguage: String = self.getTranslatedLanguageName.getLanguageName(language: languageModel, translatedInLanguage: languageModel.code)
                                        
                    self.cache.storeTranslatedLanguage(
                        language: languageModel,
                        languageTranslation: language,
                        translatedName: languageNameTranslatedInLanguage
                    )
                    
                    self.cache.storeTranslatedLanguage(
                        language: languageModel,
                        languageTranslation: languageModel.code,
                        translatedName: languageNameTranslatedInOwnLanguage
                    )
                    
                    print("\n cache language translation for language: \(languageModel.code)")
                    print("  languageNameTranslatedInLanguage: \(languageNameTranslatedInLanguage)")
                    print("  languageNameTranslatedInOwnLanguage: \(languageNameTranslatedInOwnLanguage)")
                }
                
                return Just(())
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
