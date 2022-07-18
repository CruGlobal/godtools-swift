//
//  GetLanguageAvailablityStringUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetLanguageAvailabilityStringUseCase {
    
    let resource: ResourceModel
    let localizationServices: LocalizationServices
    
    init(resource: ResourceModel, localizationServices: LocalizationServices) {
        self.resource = resource
        self.localizationServices = localizationServices
    }
    
    func getLanguageAvailability(language: LanguageModel?) -> (isAvailable: Bool, string: String) {
        guard let language = language else {
            return (false, "")
        }
        
        let languageViewModel = LanguageViewModel(language: language, localizationServices: localizationServices)
        
        if resource.supportsLanguage(languageId: language.id) {
            
            let string = languageViewModel.translatedLanguageName + " ✓"
            return (true, string)
            
        } else {
            
            let string = "Not available in " + languageViewModel.translatedLanguageName + " ✕"
            return (false, string)
        }
    }
}
