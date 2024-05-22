//
//  TranslatedLanguageNameRepositorySync.swift
//  godtools
//
//  Created by Levi Eggert on 1/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine
import RealmSwift

class TranslatedLanguageNameRepositorySync {
    
    private let realmDatabase: RealmDatabase
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    private let cache: RealmTranslatedLanguageNameCache
    
    init(realmDatabase: RealmDatabase, getTranslatedLanguageName: GetTranslatedLanguageName, cache: RealmTranslatedLanguageNameCache) {
        
        self.realmDatabase = realmDatabase
        self.getTranslatedLanguageName = getTranslatedLanguageName
        self.cache = cache
    }
    
    func syncTranslatedLanguageNamesPublisher(translateInLanguage: BCP47LanguageIdentifier, languages: [LanguageModel]) -> AnyPublisher<Void, Never> {
        
        return realmDatabase.writeObjectsPublisher { (realm: Realm) -> [RealmTranslatedLanguageName] in
            
            var translatedLanguageNames: [RealmTranslatedLanguageName] = Array()
            
            for languageModel in languages {
                
                if let realmObject = self.getRealmTranslatedLanguage(realm: realm, language: languageModel, translateInLanguage: translateInLanguage) {
                    translatedLanguageNames.append(realmObject)
                }
                
                if let realmObject = self.getRealmTranslatedLanguage(realm: realm, language: languageModel, translateInLanguage: languageModel.code) {
                    translatedLanguageNames.append(realmObject)
                }
            }
            
            return translatedLanguageNames
            
        } mapInBackgroundClosure: { (objects: [RealmTranslatedLanguageName]) -> [Void] in
            return [Void()]
        }
        .map { _ in
            return ()
        }
        .catch ({ (error: Error) in
            return Just(())
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
    
    private func getRealmTranslatedLanguage(realm: Realm, language: TranslatableLanguage, translateInLanguage: BCP47LanguageIdentifier) -> RealmTranslatedLanguageName? {
        
        guard let realmTranslatedLanguage = cache.getExistingTranslatedLanguageNameElseNew(realm: realm, language: language, languageTranslation: translateInLanguage) else {
            return nil
        }
        
        let translatedName: String = getTranslatedLanguageName.getLanguageName(
            language: language,
            translatedInLanguage: translateInLanguage
        )
        
        guard !translatedName.isEmpty else {
            return nil
        }
        
        realmTranslatedLanguage.language = language.localeId
        realmTranslatedLanguage.languageTranslation = translateInLanguage
        realmTranslatedLanguage.translatedName = translatedName
                
        return realmTranslatedLanguage
    }
}
