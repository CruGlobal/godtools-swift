//
//  PreferredLanguageTranslationViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class PreferredLanguageTranslationViewModel {
    
    private let realmDatabase: RealmDatabase
    private let languageSettingsCache: LanguageSettingsCacheType
    private let deviceLanguage: DeviceLanguageType
    
    required init(realmDatabase: RealmDatabase, languageSettingsCache: LanguageSettingsCacheType, deviceLanguage: DeviceLanguageType) {
        
        self.realmDatabase = realmDatabase
        self.languageSettingsCache = languageSettingsCache
        self.deviceLanguage = deviceLanguage
    }
    
    func getPreferredLanguageTranslation(resourceId: String, completeOnMain: @escaping ((_ result: PreferredLanguageTranslationResult) -> Void)) {
                        
        realmDatabase.background { [unowned self] (realm: Realm) in
            
            let result: PreferredLanguageTranslationResult = self.getPreferredLanguageTranslation(realm: realm, resourceId: resourceId)

            DispatchQueue.main.async {
                completeOnMain(result)
            }
        }
    }
    
    private func getPreferredLanguageTranslation(realm: Realm, resourceId: String) -> PreferredLanguageTranslationResult {
    
        let primaryLanguageId: String = languageSettingsCache.primaryLanguageId.value ?? ""
        let realmPrimaryLanguage: RealmLanguage? = realm.object(ofType: RealmLanguage.self, forPrimaryKey: primaryLanguageId)
        let resourceLatestTranslations: List<RealmTranslation> = realm.object(ofType: RealmResource.self, forPrimaryKey: resourceId)?.latestTranslations ?? List<RealmTranslation>()

        // check if resource supports settings primary language and return language and translation
        if let realmPrimaryLanguage = realmPrimaryLanguage,
            let realmPrimaryTranslation = resourceLatestTranslations.filter("language.id = '\(realmPrimaryLanguage.id)'").first {
            
            return PreferredLanguageTranslationResult(
                resourceId: resourceId,
                primaryLanguage: LanguageModel(realmLanguage: realmPrimaryLanguage),
                primaryLanguageTranslation: TranslationModel(realmTranslation: realmPrimaryTranslation),
                fallbackLanguage: nil,
                fallbackLanguageTranslation: nil
            )
        }
        
        // fallback to device locale language and translation if supported
        let localeLanguageCodes: [String] = deviceLanguage.possibleLocaleCodes(locale: Locale.current)
        
        for code in localeLanguageCodes {
            
            if let realmDeviceLocaleTranslation = resourceLatestTranslations.filter(NSPredicate(format: "language.code".appending(" = [c] %@"), code.lowercased())).first,
                let realmDeviceLocaleLanguage = realmDeviceLocaleTranslation.language {
                                
                return PreferredLanguageTranslationResult(
                    resourceId: resourceId,
                    primaryLanguage: nil,
                    primaryLanguageTranslation: nil,
                    fallbackLanguage: LanguageModel(realmLanguage: realmDeviceLocaleLanguage),
                    fallbackLanguageTranslation: TranslationModel(realmTranslation: realmDeviceLocaleTranslation)
                )
            }
        }
        
        // return English language and translation
        if let realmEnglishTranslation = resourceLatestTranslations.filter("language.code = 'en'").first,
            let realmEnglishLanguage = realmEnglishTranslation.language {
            
            return PreferredLanguageTranslationResult(
                resourceId: resourceId,
                primaryLanguage: nil,
                primaryLanguageTranslation: nil,
                fallbackLanguage: LanguageModel(realmLanguage: realmEnglishLanguage),
                fallbackLanguageTranslation: TranslationModel(realmTranslation: realmEnglishTranslation)
            )
        }
        
        // this is very unlikely and would only occur if data did not exist in realm
        return PreferredLanguageTranslationResult(
            resourceId: resourceId,
            primaryLanguage: nil,
            primaryLanguageTranslation: nil,
            fallbackLanguage: nil,
            fallbackLanguageTranslation: nil
        )
    }
}
