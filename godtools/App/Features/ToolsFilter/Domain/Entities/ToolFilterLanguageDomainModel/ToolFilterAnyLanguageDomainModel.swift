//
//  ToolFilterAnyLanguageDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/25/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class ToolFilterAnyLanguageDomainModel: ToolFilterLanguageDomainModel {
        
    init(text: String, toolsAvailableText: String) {
        
        super.init(
            id: nil,
            filterId: "any_language",
            languageDataModelId: nil,
            languageLocale: nil,
            languageButtonText: text,
            primaryText: text,
            translatedName: nil,
            toolsAvailableText: toolsAvailableText,
            searchableStrings: [text]
        )
    }
}
