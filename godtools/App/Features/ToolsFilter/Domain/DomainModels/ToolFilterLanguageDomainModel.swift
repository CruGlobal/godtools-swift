//
//  ToolFilterLanguageDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 9/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ToolFilterLanguageDomainModel: ToolLanguageFilterItemDomainModelInterface {
    
    static let anyId: String = "any_language"
    
    enum LanguageType: Sendable {
        case any
        case language
    }
    
    let id: String
    let languageId: String?
    let languageNamePair: TranslatedLanguageNamePairDomainModel
    let toolsAvailableText: String
    let toolsAvailableCount: Int
    let languageType: LanguageType
    
    var filterLanguageId: String? {
        return languageId
    }
    
    var availableText: String? {
        return toolsAvailableText
    }
    
    var isAny: Bool {
        return languageType == .any
    }
    
    static func createAnyLanguage(
        nameInAppLanguage: String,
        toolsAvailableText: String,
        toolsAvailableCount: Int
    ) -> ToolFilterLanguageDomainModel {
        
        return ToolFilterLanguageDomainModel(
            id: Self.anyId,
            languageId: nil,
            languageNamePair: TranslatedLanguageNamePairDomainModel(
                nameInOwnLanguage: "",
                nameInAppLanguage: nameInAppLanguage
            ),
            toolsAvailableText: toolsAvailableText,
            toolsAvailableCount: toolsAvailableCount,
            languageType: .any
        )
    }
    
    static func createLanguage(
        languageId: String,
        languageNamePair: TranslatedLanguageNamePairDomainModel,
        toolsAvailableText: String,
        toolsAvailableCount: Int
    ) -> ToolFilterLanguageDomainModel {
        
        return ToolFilterLanguageDomainModel(
            id: languageId,
            languageId: languageId,
            languageNamePair: languageNamePair,
            toolsAvailableText: toolsAvailableText,
            toolsAvailableCount: toolsAvailableCount,
            languageType: .language
        )
    }
    
    static var emptyValue: ToolFilterLanguageDomainModel {
        return Self.createAnyLanguage(nameInAppLanguage: "", toolsAvailableText: "", toolsAvailableCount: 0)
    }
}

extension ToolFilterLanguageDomainModel: StringSearchable {
    
    var searchableStrings: [String] {
        
        switch languageType {
            
        case .any:
            return [languageNamePair.nameInAppLanguage]
        case .language:
            return [languageNamePair.nameInOwnLanguage, languageNamePair.nameInAppLanguage]
        }
    }
}
