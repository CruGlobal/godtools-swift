//
//  GetTranslatedLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 6/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetTranslatedLanguageUseCase {
    
    private let languagesRepository: LanguagesRepository
    private let localizationServices: LocalizationServices
    
    init(languagesRepository: LanguagesRepository, localizationServices: LocalizationServices) {
        
        self.languagesRepository = languagesRepository
        self.localizationServices = localizationServices
    }
    
    func getTranslatedLanguage(languageId: String) -> TranslatedLanguage? {
        
        guard let language = languagesRepository.getLanguage(id: languageId) else {
            return nil
        }
        
        return getTranslatedLanguage(language: language)
    }
    
    func getTranslatedLanguage(language: LanguageModel) -> TranslatedLanguage {
        
        let strippedCode: String = language.code.components(separatedBy: "-x-")[0]

        let localizedKey: String = "language_name_" + language.code
        let localizedName: String = localizationServices.stringForBundle(bundle: Bundle.main, key: localizedKey)
        
        var translatedLanguageName: String
        
        if !localizedName.isEmpty && localizedName != localizedKey {
            translatedLanguageName = localizedName
        }
        else if let localeName = Locale.current.localizedString(forIdentifier: strippedCode), !localeName.isEmpty {
            translatedLanguageName = localeName
        }
        else {
            translatedLanguageName = language.name
        }
                        
        if translatedLanguageName.contains(", ") {
            let names: [String] = translatedLanguageName.components(separatedBy: ", ")
            if names.count == 2 {
                translatedLanguageName = names[0] + " (" + names[1] + ")"
            }
        }
                
        return TranslatedLanguage(
            id: language.id,
            name: translatedLanguageName
        )
    }
}
