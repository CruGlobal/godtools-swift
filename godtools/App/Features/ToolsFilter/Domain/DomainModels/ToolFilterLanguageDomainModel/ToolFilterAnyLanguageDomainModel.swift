//
//  ToolFilterAnyLanguageDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/25/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class ToolFilterAnyLanguageDomainModel: ToolFilterLanguageDomainModel {
    
    private static let anyFilterId: String = "any_language"
        
    init(text: String, toolsAvailableText: String, numberOfToolsAvailable: Int) {
        
        super.init(
            id: nil,
            filterId: Self.anyFilterId,
            languageDataModelId: nil,
            languageLocale: nil,
            languageButtonText: text,
            primaryText: text,
            translatedName: nil,
            toolsAvailableText: toolsAvailableText,
            searchableStrings: [text],
            numberOfToolsAvailable: numberOfToolsAvailable
        )
    }
    
    static var emptyValue: ToolFilterAnyLanguageDomainModel {
        return ToolFilterAnyLanguageDomainModel(text: "", toolsAvailableText: "", numberOfToolsAvailable: 0)
    }
}
