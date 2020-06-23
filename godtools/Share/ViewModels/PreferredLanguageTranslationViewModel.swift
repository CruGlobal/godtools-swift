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
    
    private let resourcesCache: RealmResourcesCache
    private let languageSettingsCache: LanguageSettingsCacheType
    private let deviceLanguage: DeviceLanguageType
    
    required init(resourcesCache: RealmResourcesCache, languageSettingsCache: LanguageSettingsCacheType, deviceLanguage: DeviceLanguageType) {
        
        self.resourcesCache = resourcesCache
        self.languageSettingsCache = languageSettingsCache
        self.deviceLanguage = deviceLanguage
    }
    
    func getPreferredLanguageTranslation(resourceId: String, completeOnMain: @escaping ((_ result: PreferredLanguageTranslationResult) -> Void)) {
                        
        resourcesCache.realmDatabase.background { [unowned self] (realm: Realm) in
            
            let result: PreferredLanguageTranslationResult = self.getPreferredLanguageTranslation(realm: realm, resourceId: resourceId)

            DispatchQueue.main.async {
                completeOnMain(result)
            }
        }
    }
    
    func getPreferredLanguageTranslation(realm: Realm, resourceId: String) -> PreferredLanguageTranslationResult {
         
        let userPrimaryLanguageId: String = languageSettingsCache.primaryLanguageId.value ?? ""
        let userPrimaryLanguage: RealmLanguage? = realm.object(ofType: RealmLanguage.self, forPrimaryKey: userPrimaryLanguageId)
        let resourceSupportsPrimaryLanguage: Bool
        let languageLocale: Locale
        var fallbackLanguageCode: String = ""
        let resourceLatestTranslations: List<RealmTranslation>
        var realmTranslation: RealmTranslation?
        
        if let realmResource = realm.object(ofType: RealmResource.self, forPrimaryKey: resourceId) {
            resourceLatestTranslations = realmResource.latestTranslations
        }
        else {
            resourceLatestTranslations = List<RealmTranslation>()
        }
        
        if let userPrimaryLanguage = userPrimaryLanguage {
            languageLocale = Locale(identifier: userPrimaryLanguage.code)
        }
        else {
            languageLocale = Locale.current
        }
        
        if let userPrimaryLanguage = userPrimaryLanguage, let userPrimaryLanguageTranslation = resourceLatestTranslations.filter("language.id = '\(userPrimaryLanguage.id)'").first {
            realmTranslation = userPrimaryLanguageTranslation
            resourceSupportsPrimaryLanguage = true
        }
        else {
            
            resourceSupportsPrimaryLanguage = false
            
            let localeLanguageCodes: [String] = deviceLanguage.possibleLocaleCodes(locale: languageLocale)
            
            for code in localeLanguageCodes {
                if let localeTranslation = resourceLatestTranslations.filter(NSPredicate(format: "language.code".appending(" = [c] %@"), code.lowercased())).first {
                    realmTranslation = localeTranslation
                    fallbackLanguageCode = code
                    break
                }
            }
        }
        
        if realmTranslation == nil, let englishTranslation = resourceLatestTranslations.filter("language.code = 'en'").first {
            realmTranslation = englishTranslation
            fallbackLanguageCode = "en"
        }
        
        let translation: TranslationModel?
        if let realmTranslation = realmTranslation {
            translation = TranslationModel(realmTranslation: realmTranslation)
        }
        else {
            translation = nil
        }
        
        let result = PreferredLanguageTranslationResult(
            resourceId: resourceId,
            primaryLanguageId: userPrimaryLanguageId,
            primaryLanguageTranslation: resourceSupportsPrimaryLanguage ? translation : nil,
            fallbackLanguageCode: fallbackLanguageCode,
            fallbackLanguageTranslation: !resourceSupportsPrimaryLanguage ? translation : nil,
            resourceSupportsPrimaryLanguage: resourceSupportsPrimaryLanguage
        )
        
        return result
    }
}
