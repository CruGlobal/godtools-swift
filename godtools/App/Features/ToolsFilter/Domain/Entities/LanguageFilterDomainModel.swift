//
//  LanguageFilterDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 9/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

enum LanguageFilterDomainModel {
    case anyLanguage(text: String, toolsAvailableText: String)
    case language(languageName: String, toolsAvailableText: String, languageModel: LanguageDomainModel)
}

extension LanguageFilterDomainModel: StringSearchable {
    
    var searchableStrings: [String] {
        
        switch self {
        case .anyLanguage(let text, _):
            return [text]
            
        case .language(let languageName, _, let languageModel):
            return [languageName, languageModel.translatedName]
        }
    }
}

extension LanguageFilterDomainModel {
    
    var id: String? {
        
        switch self {
        case .anyLanguage:
            return nil
            
        case .language(_, _, let languageModel):
            return languageModel.id
        }
    }
    
    var filterId: String {
        
        switch self {
        case .anyLanguage:
            return "any_language"
            
        case .language(_, _, let languageModel):
            return languageModel.id
        }
    }
    
    var primaryText: String {
        
        switch self {
        case .anyLanguage(let text, _):
            return text
            
        case .language(let languageName, _, _):
            return languageName
        }
    }
    
    var toolsAvailableText: String {
        
        switch self {
        case .anyLanguage(_, let toolsAvailableText):
            return toolsAvailableText
        case .language(_, let toolsAvailableText, _):
            return toolsAvailableText
        }
    }
    
    var translatedName: String? {
        
        switch self {
        case .anyLanguage:
            return nil
            
        case .language(_, _, let languageModel):
            return languageModel.translatedName
        }
    }
    
    var language: LanguageDomainModel? {
        
        switch self {
        case .anyLanguage:
            return nil
            
        case .language(_, _, let languageModel):
            return languageModel
        }
    }
    
    var languageButtonText: String {
    
        switch self {
        case .anyLanguage(let text, _):
            return text
            
        case .language(_, _, let languageModel):
            return languageModel.translatedName
        }
    }
}
