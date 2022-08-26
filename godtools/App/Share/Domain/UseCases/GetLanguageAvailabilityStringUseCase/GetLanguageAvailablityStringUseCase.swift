//
//  GetLanguageAvailablityStringUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetLanguageAvailabilityStringUseCase {
    
    let localizationServices: LocalizationServices
    let getTranslatedLanguageUseCase: GetTranslatedLanguageUseCase
    
    init(localizationServices: LocalizationServices, getTranslatedLanguageUseCase: GetTranslatedLanguageUseCase) {
        self.localizationServices = localizationServices
        self.getTranslatedLanguageUseCase = getTranslatedLanguageUseCase
    }
    
    func getLanguageAvailability(for resource: LanguageSupportable, language: LanguageModel?) -> (isAvailable: Bool, string: String) {
        guard let language = language else {
            return (false, "")
        }
        
        let translatedLanguageName = getTranslatedLanguageUseCase.getTranslatedLanguage(language: language).name
        
        if resource.supportsLanguage(languageId: language.id) {
            
            let string = translatedLanguageName + " ✓"
            return (true, string)
            
        } else {
            
            let notAvailableString = String.localizedStringWithFormat(
                localizationServices.stringForMainBundle(key: "lessonCard.languageNotAvailable"),
                translatedLanguageName
            )
            let stringWithX = notAvailableString + " ✕"
            
            return (false, stringWithX)
        }
    }
}
