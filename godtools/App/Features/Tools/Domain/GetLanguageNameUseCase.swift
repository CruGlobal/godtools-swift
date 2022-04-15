//
//  GetLanguageNameUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol GetLanguageNameUseCase {
    func getLanguageName(language: LanguageModel?) -> String
}

// MARK: - Default

class DefaultGetLanguageNameUseCase: GetLanguageNameUseCase {
    
    private let resource: ResourceModel
    private let localizationServices: LocalizationServices
    
    init(resource: ResourceModel, localizationServices: LocalizationServices) {
        self.resource = resource
        self.localizationServices = localizationServices
    }
    
    func getLanguageName(language: LanguageModel?) -> String {
        
        if let language = language {
            
            if resource.supportsLanguage(languageId: language.id) {
                let nameAvailableSuffix: String = " ✓"
                let translatedName: String = LanguageViewModel(language: language, localizationServices: localizationServices).translatedLanguageName
                
                return translatedName + nameAvailableSuffix
            }
        }
        return ""
    }
}

// MARK: - Mock

class MockGetDefaultLanguageNameUseCase: GetLanguageNameUseCase {
    func getLanguageName(language: LanguageModel?) -> String {
        return "French ✓"
    }
}
