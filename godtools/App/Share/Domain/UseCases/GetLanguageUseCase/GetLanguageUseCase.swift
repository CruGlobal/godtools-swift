//
//  GetLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetLanguageUseCase {
    
    private let languagesRepository: LanguagesRepository
    private let localizationServices: LocalizationServices
    
    init(languagesRepository: LanguagesRepository, localizationServices: LocalizationServices) {
        
        self.languagesRepository = languagesRepository
        self.localizationServices = localizationServices
    }
    
    func getLanguage(id: String) -> LanguageDomainModel? {
        
        guard let language = languagesRepository.getLanguage(id: id) else {
            return nil
        }
        
        return getLanguage(language: language)
    }
    
    func getLanguage(locale: Locale) -> LanguageDomainModel? {
        
        if let language = languagesRepository.getLanguage(code: locale.identifier) {
            
            return getLanguage(language: language)
        }
        else if let languageCode = locale.languageCode, let language = languagesRepository.getLanguage(code: languageCode) {
            
            return getLanguage(language: language)
        }
                
        return nil
    }
    
    func getLanguage(language: LanguageModel) -> LanguageDomainModel {
                        
        return LanguageDomainModel(
            analyticsContentLanguage: language.code,
            dataModelId: language.id,
            direction: language.direction == "rtl" ? .rightToLeft : .leftToRight,
            localeIdentifier: language.code,
            translatedName: getTranslatedName(language: language, localizationServices: localizationServices)
        )
    }
    
    private func getLocaleLanguageCode(locale: Locale) -> String {
        return (locale.languageCode ?? locale.identifier).lowercased()
    }

    private func getTranslatedName(language: LanguageModel, localizationServices: LocalizationServices) -> String {
                
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
                
        return translatedLanguageName
    }
}
