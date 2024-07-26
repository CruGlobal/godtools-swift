//
//  ToolFilterLanguageDomainModelInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 7/25/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

protocol ToolFilterLanguageDomainModelInterface: StringSearchable {
    
    var id: String? { get }
    var filterId: String { get }
    var primaryText: String { get }
    var toolsAvailableText: String { get }
    var translatedName: String? { get }
    var languageDataModelId: String? { get }
    var languageLocale: BCP47LanguageIdentifier? { get }
    var languageButtonText: String { get }
}
