//
//  ToolFilterLanguageDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 9/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ToolFilterLanguageDomainModel: ToolFilterLanguageDomainModelInterface {
    
    let languageName: String
    let toolsAvailableText: String
    
    private let _translatedName: String
    private let _language: LanguageDomainModel
    
    init(languageName: String, translatedName: String, toolsAvailableText: String, language: LanguageDomainModel) {
        self.languageName = languageName
        self.toolsAvailableText = toolsAvailableText
        self._translatedName = translatedName
        self._language = language
    }
    
    var id: String? {
        return _language.id
    }
    
    var filterId: String {
        return _language.id
    }
    
    var language: LanguageDomainModel? {
        return _language
    }
    
    var languageButtonText: String {
        return _translatedName
    }
    
    var primaryText: String {
        return languageName
    }
    
    var translatedName: String? {
        return _translatedName
    }
    
    var searchableStrings: [String] {
        var searchableStrings = [languageName]
        
        if let translatedName = translatedName {
            searchableStrings.append(translatedName)
        }
        
        return searchableStrings
    }
}
