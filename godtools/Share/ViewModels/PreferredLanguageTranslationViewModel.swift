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
    
    func getPreferredLanguageTranslation(resourceId: String, complete: @escaping ((_ translation: TranslationModel?) -> Void)) {
                
        let userPrimaryLanguageId: String = languageSettingsCache.primaryLanguageId.value ?? ""
        
        realmDatabase.background { [weak self] (realm: Realm) in
            
            let translation: TranslationModel?
            var realmTranslation: RealmTranslation?
            
            if let realmResource = realm.object(ofType: RealmResource.self, forPrimaryKey: resourceId) {
                
                if !userPrimaryLanguageId.isEmpty, let userPrimaryLanguageTranslation = realmResource.latestTranslations.filter("language.id = '\(userPrimaryLanguageId)'").first {
                    realmTranslation = userPrimaryLanguageTranslation
                }
                else if let localeLanguageCodes = self?.deviceLanguage.possibleLocaleCodes(locale: Locale.current) {
                    for code in localeLanguageCodes {
                        if let localeTranslation = realmResource.latestTranslations.filter(NSPredicate(format: "language.code".appending(" = [c] %@"), code.lowercased())).first {
                            realmTranslation = localeTranslation
                            break
                        }
                    }
                }
                else if let englishTranslation = realmResource.latestTranslations.filter("language.code = 'en'").first {
                    realmTranslation = englishTranslation
                }
            }
            
            if let realmTranslation = realmTranslation {
                translation = TranslationModel(realmTranslation: realmTranslation)
            }
            else {
                translation = nil
            }
            
            DispatchQueue.main.async {
                complete(translation)
            }
        }
    }
}
