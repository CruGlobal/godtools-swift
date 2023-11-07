//
//  LanguageFilterDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 9/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct LanguageFilterDomainModel {
    
    let type: LanguageFilterType
    let languageName: String
    let toolsAvailableText: String
    let searchableText: String
}

extension LanguageFilterDomainModel: StringSearchable {
    
    var searchableStrings: [String] {
        return [searchableText]
    }
}

extension LanguageFilterDomainModel {
    
    var id: String? {
        
        switch type {
        case .anyLanguage:
            return nil
            
        case .language(let languageModel):
            return languageModel.id
        }
    }
    
    var filterId: String {
        
        switch type {
        case .anyLanguage:
            return "any_language"
            
        case .language(let languageModel):
            return languageModel.id
        }
    }
    
    var translatedName: String? {
        
        switch type {
        case .anyLanguage:
            return nil
            
        case .language(let languageModel):
            return languageModel.translatedName
        }
    }
    
    var language: LanguageDomainModel? {
        
        switch type {
        case .anyLanguage:
            return nil
            
        case .language(let languageModel):
            return languageModel
        }
    }
}
