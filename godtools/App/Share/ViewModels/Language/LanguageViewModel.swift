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
        let strippedCode: String = language.code.components(separatedBy: "-x-")[0]

        let localizedKey: String = "language_name_" + language.code
        let localizedName: String = localizationServices.stringForBundle(bundle: Bundle.main, key: localizedKey)
        
        let translatedLanguageName: String
        
        if !localizedName.isEmpty && localizedName != localizedKey {
            translatedLanguageName = localizedName
        }
        else if let localeName = Locale.current.localizedString(forIdentifier: strippedCode), !localeName.isEmpty {
            translatedLanguageName = localeName
        }
        else {
            translatedLanguageName = language.name
        }
        
        var transformedLanguageName: String = translatedLanguageName
                
        if transformedLanguageName.contains(", ") {
            let names: [String] = translatedLanguageName.components(separatedBy: ", ")
            if names.count == 2 {
                transformedLanguageName = names[0] + " (" + names[1] + ")"
            }
        }
                
        self.translatedLanguageName = transformedLanguageName
    }
}
