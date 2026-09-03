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
    let languageNamePair: TranslatedLanguageNamePairDomainModel
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
    
    private init(
        id: String,
        languageNamePair: TranslatedLanguageNamePairDomainModel,
        toolsAvailable: String,
        numberOfToolsAvailable: Int,
        languageType: LanguageType
    ) {
        self.id = id
        self.languageNamePair = languageNamePair
        self.toolsAvailable = toolsAvailable
        self.numberOfToolsAvailable = numberOfToolsAvailable
        self.languageType = languageType
    }
    
    static func createAnyLanguage(
        nameInAppLanguage: String,
        toolsAvailable: String,
        numberOfToolsAvailable: Int
    ) -> ToolFilterLanguageDomainModel {
        
        return ToolFilterLanguageDomainModel(
            id: Self.anyLanguageId,
            languageNamePair: TranslatedLanguageNamePairDomainModel(
                nameInOwnLanguage: "",
                nameInAppLanguage: nameInAppLanguage
            ),
            toolsAvailable: toolsAvailable,
            numberOfToolsAvailable: numberOfToolsAvailable,
            languageType: .any
        )
    }
    
    static func createLanguage(
        id: String,
        languageNamePair: TranslatedLanguageNamePairDomainModel,
        toolsAvailable: String,
        numberOfToolsAvailable: Int
    ) -> ToolFilterLanguageDomainModel {
        
        return ToolFilterLanguageDomainModel(
            id: id,
            languageNamePair: languageNamePair,
            toolsAvailable: toolsAvailable,
            numberOfToolsAvailable: numberOfToolsAvailable,
            languageType: .language
        )
    }
    
    static var emptyValue: ToolFilterLanguageDomainModel {
        return Self.createAnyLanguage(nameInAppLanguage: "", toolsAvailable: "", numberOfToolsAvailable: 0)
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
