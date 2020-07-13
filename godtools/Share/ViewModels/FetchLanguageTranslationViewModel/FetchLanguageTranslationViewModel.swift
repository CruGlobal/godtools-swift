//
//  FetchLanguageTranslationViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class FetchLanguageTranslationViewModel {
        
    private let realmDatabase: RealmDatabase
    private let deviceLanguage: DeviceLanguageType
    
    required init(realmDatabase: RealmDatabase, deviceLanguage: DeviceLanguageType) {
        
        self.realmDatabase = realmDatabase
        self.deviceLanguage = deviceLanguage
    }

    func getLanguageTranslation(resourceId: String, languageId: String, supportedFallbackTypes: [FetchLanguageTranslationFallbackType]) -> FetchLanguageTranslationResult {
    
        let realm: Realm = realmDatabase.mainThreadRealm
        
        guard let realmResource = realm.object(ofType: RealmResource.self, forPrimaryKey: resourceId) else {
            return FetchLanguageTranslationResult(
                resourceId: resourceId,
                language: nil,
                translation: nil,
                type: .unableToLocateDataInCache
            )
        }
                
        let resourceLanguage: RealmLanguage? = realmResource.languages.filter("id = '\(languageId)'").first
        let resourceLatestTranslations: List<RealmTranslation> = realmResource.latestTranslations
        
        // check if resource supports provided language and return language and translation
        if let resourceLanguage = resourceLanguage, let resourceTranslation = resourceLatestTranslations.filter("language.id = '\(resourceLanguage.id)'").first {
            
            return FetchLanguageTranslationResult(
                resourceId: resourceId,
                language: LanguageModel(realmLanguage: resourceLanguage),
                translation: TranslationModel(realmTranslation: resourceTranslation),
                type: .languageSupported
            )
        }
        
        // if not falling back to a preferred language translation return that the resource does not support the given language
        guard !supportedFallbackTypes.isEmpty else {
            return FetchLanguageTranslationResult(
                resourceId: resourceId,
                language: nil,
                translation: nil,
                type: .languageNotSupported
            )
        }
        
        for fallbackType in supportedFallbackTypes {
            
            switch fallbackType {
            
            case .deviceLocaleLanguage:
                // fallback to device locale language and translation if supported
                let localeLanguageCodes: [String] = deviceLanguage.possibleLocaleCodes(locale: Locale.current)
                
                for code in localeLanguageCodes {
                    
                    if let realmDeviceLocaleTranslation = resourceLatestTranslations.filter(NSPredicate(format: "language.code".appending(" = [c] %@"), code.lowercased())).first,
                        let realmDeviceLocaleLanguage = realmDeviceLocaleTranslation.language {
                                        
                        return FetchLanguageTranslationResult(
                            resourceId: resourceId,
                            language: LanguageModel(realmLanguage: realmDeviceLocaleLanguage),
                            translation: TranslationModel(realmTranslation: realmDeviceLocaleTranslation),
                            type: .languageNotSupportedFallingBackToDeviceLocaleLanguage
                        )
                    }
                }
                
            case .englishLanguage:
                // fallback to English language and translation if available
                if let realmEnglishTranslation = resourceLatestTranslations.filter("language.code = 'en'").first,
                    let realmEnglishLanguage = realmEnglishTranslation.language {
                    
                    return FetchLanguageTranslationResult(
                        resourceId: resourceId,
                        language: LanguageModel(realmLanguage: realmEnglishLanguage),
                        translation: TranslationModel(realmTranslation: realmEnglishTranslation),
                        type: .languageNotSupportedFallingBackToEnglish
                    )
                }
            }
        }
        
        // this is very unlikely and would only occur if data did not exist in realm
        return FetchLanguageTranslationResult(
            resourceId: resourceId,
            language: nil,
            translation: nil,
            type: .unableToLocateDataInCache
        )
    }
}
