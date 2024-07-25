//
//  ToolFilterAnyLanguageDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/25/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct ToolFilterAnyLanguageDomainModel: ToolFilterLanguageDomainModelInterface {
    
    let text: String
    let toolsAvailableText: String
    
    let id: String? = nil
    let filterId: String = "any_language"
    let translatedName: String? = nil
    let language: LanguageDomainModel? = nil
    
    var primaryText: String {
        return text
    }
    
    var languageButtonText: String {
        return text
    }
    
    var searchableStrings: [String] {
        return [text]
    }
}
