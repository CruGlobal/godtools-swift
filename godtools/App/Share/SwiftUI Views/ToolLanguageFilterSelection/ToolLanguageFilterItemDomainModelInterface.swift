//
//  ToolLanguageFilterItemDomainModelInterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/2/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol ToolLanguageFilterItemDomainModelInterface: Sendable, Identifiable, StringSearchable {
    
    var languageId: String { get }
    var languageNamePair: TranslatedLanguageNamePairDomainModel { get }
    var availableText: String? { get }
}

extension ToolLanguageFilterItemDomainModelInterface  {
    var id: String {
        return languageId
    }
}

extension ToolLanguageFilterItemDomainModelInterface {
    var searchableStrings: [String] {
        return [languageNamePair.nameInOwnLanguage, languageNamePair.nameInAppLanguage]
    }
}
