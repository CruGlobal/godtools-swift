//
//  ToolFilterLanguageDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 9/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ToolFilterLanguageDomainModel: Sendable, Identifiable {
    
    private static let anyLanguageId: String = "any_language"
    
    enum LanguageType: Sendable {
        case any
        case language
    }
    
    let id: String
    let languageName: String?
    let languageNameTranslatedInAppLanguage: String
    let toolsAvailable: String
    let numberOfToolsAvailable: Int
    let languageType: LanguageType
    
    var filterId: String? {
        switch languageType {
        case .any:
            return nil
        case .language:
            return id
        }
    }
    
    private init(id: String, languageName: String?, languageNameTranslatedInAppLanguage: String, toolsAvailable: String, numberOfToolsAvailable: Int, languageType: LanguageType) {
        self.id = id
        self.languageName = languageName
        self.languageNameTranslatedInAppLanguage = languageNameTranslatedInAppLanguage
        self.toolsAvailable = toolsAvailable
        self.numberOfToolsAvailable = numberOfToolsAvailable
        self.languageType = languageType
    }
    
    static func createAnyLanguage(languageNameTranslatedInAppLanguage: String, toolsAvailable: String, numberOfToolsAvailable: Int) -> ToolFilterLanguageDomainModel {
        
        return ToolFilterLanguageDomainModel(
            id: Self.anyLanguageId,
            languageName: nil,
            languageNameTranslatedInAppLanguage: languageNameTranslatedInAppLanguage,
            toolsAvailable: toolsAvailable,
            numberOfToolsAvailable: numberOfToolsAvailable,
            languageType: .any
        )
    }
    
    static func createLanguage(id: String, languageName: String, languageNameTranslatedInAppLanguage: String, toolsAvailable: String, numberOfToolsAvailable: Int) -> ToolFilterLanguageDomainModel {
        
        return ToolFilterLanguageDomainModel(
            id: id,
            languageName: languageName,
            languageNameTranslatedInAppLanguage: languageNameTranslatedInAppLanguage,
            toolsAvailable: toolsAvailable,
            numberOfToolsAvailable: numberOfToolsAvailable,
            languageType: .language
        )
    }
    
    static var emptyValue: ToolFilterLanguageDomainModel {
        return Self.createAnyLanguage(languageNameTranslatedInAppLanguage: "", toolsAvailable: "", numberOfToolsAvailable: 0)
    }
}

extension ToolFilterLanguageDomainModel: StringSearchable {
    
    var searchableStrings: [String] {
        
        if let languageName = languageName, !languageName.isEmpty {
            return [languageName, languageNameTranslatedInAppLanguage]
        }
        
        return [languageNameTranslatedInAppLanguage]
    }
}
