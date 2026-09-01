//
//  ToolLanguageFilterItemDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct ToolLanguageFilterItemDomainModel: Sendable {
    
    let languageId: String
    let languageNameTranslatedInLanguage: String
    let languageNameTranslatedInAppLanguage: String
    let availableText: String?
}

extension ToolLanguageFilterItemDomainModel: StringSearchable {
    
    var searchableStrings: [String] {
        return [languageNameTranslatedInLanguage, languageNameTranslatedInAppLanguage]
    }
}

extension ToolLanguageFilterItemDomainModel: Identifiable {
    
    var id: String {
        return languageId
    }
}
