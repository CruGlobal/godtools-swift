//
//  RealmTranslatedLanguageNameCache.swift
//  godtools
//
//  Created by Levi Eggert on 1/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmTranslatedLanguageNameCache {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    private func getPrimaryKey(language: TranslatableLanguage, languageTranslation: BCP47LanguageIdentifier) -> String? {
        
        let localeId: String = language.localeId
        
        guard !localeId.isEmpty && !languageTranslation.isEmpty else {
            return nil
        }
        
        return localeId.lowercased() + "-" + languageTranslation.lowercased()
    }
    
    private func getTranslatedLanguageName(realm: Realm, language: TranslatableLanguage, languageTranslation: BCP47LanguageIdentifier) -> RealmTranslatedLanguageName?  {
                
        guard let primaryKey = getPrimaryKey(language: language, languageTranslation: languageTranslation) else {
            return nil
        }
        
        return realm.object(ofType: RealmTranslatedLanguageName.self, forPrimaryKey: primaryKey)
    }
    
    func getExistingTranslatedLanguageNameElseNew(realm: Realm, language: TranslatableLanguage, languageTranslation: BCP47LanguageIdentifier) -> RealmTranslatedLanguageName? {
        
        if let existingObject = getTranslatedLanguageName(realm: realm, language: language, languageTranslation: languageTranslation) {
            
            return existingObject
        }
        else if let primarykey = getPrimaryKey(language: language, languageTranslation: languageTranslation) {
            
            let newObject = RealmTranslatedLanguageName()
            newObject.id = primarykey
            
            return newObject
        }
        
        return nil
    }
    
    func getTranslatedLanguageName(language: TranslatableLanguage, languageTranslation: BCP47LanguageIdentifier) -> TranslatedLanguageNameDataModel? {
        
        guard let realmObject = getTranslatedLanguageName(realm: realmDatabase.openRealm(), language: language.localeId, languageTranslation: languageTranslation) else {
            return nil
        }
        
        return TranslatedLanguageNameDataModel(realmObject: realmObject)
    }
    
    func storeTranslatedLanguage(language: TranslatableLanguage, languageTranslation: BCP47LanguageIdentifier, translatedName: String) {
        
        guard let primaryKey = self.getPrimaryKey(language: language, languageTranslation: languageTranslation) else {
            return
        }
        
        realmDatabase.writeObjectsInBackground { (realm: Realm) -> [RealmTranslatedLanguageName] in
            
            let realmObject: RealmTranslatedLanguageName
            
            if let existingObject = self.getTranslatedLanguageName(realm: realm, language: language, languageTranslation: languageTranslation) {
                
                existingObject.translatedName = translatedName
                existingObject.updatedAt = Date()
                
                realmObject = existingObject
            }
            else {
                
                let newObject = RealmTranslatedLanguageName()
                
                newObject.createdAt = Date()
                newObject.id = primaryKey
                newObject.language = language.localeId
                newObject.languageTranslation = languageTranslation
                newObject.translatedName = translatedName
                newObject.updatedAt = Date()
                
                realmObject = newObject
            }

            return [realmObject]
            
        } mapInBackgroundClosure: { (objects: [RealmTranslatedLanguageName]) -> [RealmTranslatedLanguageName] in
            
            return objects
            
        } completion: { (result: Result<[RealmTranslatedLanguageName], Error>) in
            
        }
    }
}
