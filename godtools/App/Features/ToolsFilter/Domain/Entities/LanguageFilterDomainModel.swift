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
    let languageButtonText: String
}

extension LanguageFilterDomainModel: StringSearchable {
    
    var searchableStrings: [String] {
        var searchableStrings = [languageName]
        
        if let translatedName = translatedName {
            searchableStrings.append(translatedName)
        }
       
        return searchableStrings
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
