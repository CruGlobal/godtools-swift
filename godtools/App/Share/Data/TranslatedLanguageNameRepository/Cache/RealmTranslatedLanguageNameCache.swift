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
    
    private func getTranslatedLanguageName(realm: Realm, language: BCP47LanguageIdentifier, languageTranslation: BCP47LanguageIdentifier) -> RealmTranslatedLanguageName?  {
        
        let languageFilter = NSPredicate(format: "\(#keyPath(RealmTranslatedLanguageName.language)) == [c] %@", language.lowercased())
        let languageTranslationFilter = NSPredicate(format: "\(#keyPath(RealmTranslatedLanguageName.languageTranslation)) == [c] %@", languageTranslation.lowercased())
        
        let filterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [languageFilter, languageTranslationFilter])
                
        let filteredTranslatedLanguageNames = realm.objects(RealmTranslatedLanguageName.self).filter(filterPredicate)
        
        if filteredTranslatedLanguageNames.count > 1 {
            assertionFailure("Found more than 1 translation.  There should be max 1 translation stored per language and language translation.")
        }
        
        return filteredTranslatedLanguageNames.first
    }
    
    func getTranslatedLanguageName(language: BCP47LanguageIdentifier, languageTranslation: BCP47LanguageIdentifier) -> TranslatedLanguageNameDataModel? {
        
        guard let realmObject = getTranslatedLanguageName(realm: realmDatabase.openRealm(), language: language, languageTranslation: languageTranslation) else {
            return nil
        }
        
        return TranslatedLanguageNameDataModel(realmObject: realmObject)
    }
    
    func storeTranslatedLanguage(language: BCP47LanguageIdentifier, languageTranslation: BCP47LanguageIdentifier, translatedName: String) {
        
        realmDatabase.writeObjectsInBackground { (realm: Realm) in
                        
            let realmObject: RealmTranslatedLanguageName
            
            if let existingObject = self.getTranslatedLanguageName(realm: realm, language: language, languageTranslation: languageTranslation) {
                
                realmObject = existingObject
                realmObject.translatedName = translatedName
                realmObject.updatedAt = Date()
            }
            else {
                
                let newObject = RealmTranslatedLanguageName()
                
                newObject.createdAt = Date()
                newObject.id = UUID().uuidString
                newObject.language = language
                newObject.languageTranslation = languageTranslation
                newObject.translatedName = translatedName
                newObject.updatedAt = Date()
                
                realmObject = newObject
            }
            
            return [realmObject]
            
        } completion: { (result: Result<[RealmTranslatedLanguageName], Error>) in
            
        }
    }
}
