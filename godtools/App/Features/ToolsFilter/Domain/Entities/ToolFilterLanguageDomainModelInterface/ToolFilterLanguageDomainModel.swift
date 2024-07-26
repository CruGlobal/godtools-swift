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
    
    private let translatedLanguageName: String
    private let languageId: String
    private let languageLocaleId: BCP47LanguageIdentifier
    
    init(languageName: String, translatedName: String, toolsAvailableText: String, languageId: String, languageLocaleId: BCP47LanguageIdentifier) {
        self.languageName = languageName
        self.toolsAvailableText = toolsAvailableText
        self.translatedLanguageName = translatedName
        self.languageId = languageId
        self.languageLocaleId = languageLocaleId
    }
    
    var id: String? {
        return languageId
    }
    
    var filterId: String {
        return languageId
    }
    
    var languageDataModelId: String? {
        return languageId
    }
    
    var languageLocale: BCP47LanguageIdentifier? {
        return languageLocaleId
    }
    
    var languageButtonText: String {
        return translatedLanguageName
    }
    
    var primaryText: String {
        return languageName
    }
    
    var translatedName: String? {
        return translatedLanguageName
    }
    
    var searchableStrings: [String] {
        return [languageName, translatedLanguageName]
    }
}
