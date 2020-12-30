//
//  LanguageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LanguageViewModel {
        
    let language: LanguageModel
    let translatedLanguageName: String
    
    required init(language: LanguageModel, localizationServices: LocalizationServices) {
                
        self.language = language
        
        let localizedKey: String = "language_name_" + language.code
        let localizedName: String = localizationServices.stringForBundle(bundle: Bundle.main, key: localizedKey)
        
        if !localizedName.isEmpty && localizedName != localizedKey {
            translatedLanguageName = localizedName
        }
        else if let localeName = Locale.current.localizedString(forIdentifier: language.code), !localeName.isEmpty {
            translatedLanguageName = localeName
        }
        else {
            translatedLanguageName = language.name
        }
    }
}
