//
//  TranslateLanguageNameViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/15/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TranslateLanguageNameViewModel {

    private let localizationServices: LocalizationServices
        
    required init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getLocalizedLanguageNameForLanguage(language: LanguageModelType, localizedBundle: Bundle) -> String? {
        
        let key: String = "language_name_" + language.code
        let localizedName: String = localizationServices.stringForBundle(bundle: localizedBundle, key: key)
        
        if !localizedName.isEmpty && localizedName != key {
            return localizedName
        }
        
        return nil
    }
    
    func getTranslatedName(language: LanguageModelType) -> String {
        
        let deviceBundle: Bundle = Bundle.main
        
        if let localizedName = getLocalizedLanguageNameForLanguage(language: language, localizedBundle: deviceBundle) {
            
            return localizedName
        }
        
        let deviceLocale: Locale = Locale.current
        
        if let localeName = deviceLocale.localizedString(forIdentifier: language.code), !localeName.isEmpty {
            return localeName
        }
        
        return language.name
    }
}
