//
//  GetLanguageAvailablityUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetLanguageAvailabilityUseCase {
    
    let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        self.localizationServices = localizationServices
    }
    
    func getLanguageAvailability(for resource: LanguageSupportable, language: LanguageDomainModel?) -> LanguageAvailabilityDomainModel {
        guard let language = language else {
            return LanguageAvailabilityDomainModel(availabilityString: "", isAvailable: false)
        }
        
        let translatedLanguageName = language.translatedName
        
        if resource.supportsLanguage(languageId: language.id) {
            
            let string = translatedLanguageName + " ✓"
            return LanguageAvailabilityDomainModel(availabilityString: string, isAvailable: true)
            
        } else {
            
            let notAvailableString = String.localizedStringWithFormat(
                localizationServices.stringForMainBundle(key: "lessonCard.languageNotAvailable"),
                translatedLanguageName
            )
            let stringWithX = notAvailableString + " ✕"
            
            return LanguageAvailabilityDomainModel(availabilityString: stringWithX, isAvailable: false)
        }
    }
}
