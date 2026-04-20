//
//  ToolFilterLanguageDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 9/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolFilterLanguageDomainModel: StringSearchable {
    
    let id: String?
    let filterId: String
    let languageDataModelId: String?
    let languageLocale: BCP47LanguageIdentifier?
    let languageButtonText: String
    let primaryText: String
    let translatedName: String?
    let toolsAvailableText: String
    let numberOfToolsAvailable: Int
    let searchableStrings: [String]
    
    convenience init(languageName: String, translatedName: String, toolsAvailableText: String, languageId: String, languageLocaleId: BCP47LanguageIdentifier, numberOfToolsAvailable: Int) {
        
        self.init(
            id: languageId,
            filterId: languageId,
            languageDataModelId: languageId,
            languageLocale: languageLocaleId,
            languageButtonText: translatedName,
            primaryText: languageName,
            translatedName: translatedName,
            toolsAvailableText: toolsAvailableText,
            searchableStrings: [languageName, translatedName],
            numberOfToolsAvailable: numberOfToolsAvailable
        )
    }
    
    init(id: String?, filterId: String, languageDataModelId: String?, languageLocale: BCP47LanguageIdentifier?, languageButtonText: String, primaryText: String, translatedName: String?, toolsAvailableText: String, searchableStrings: [String], numberOfToolsAvailable: Int) {
        
        self.id = id
        self.filterId = filterId
        self.languageDataModelId = languageDataModelId
        self.languageLocale = languageLocale
        self.languageButtonText = languageButtonText
        self.primaryText = primaryText
        self.translatedName = translatedName
        self.toolsAvailableText = toolsAvailableText
        self.searchableStrings = searchableStrings
        self.numberOfToolsAvailable = numberOfToolsAvailable
    }
}
