//
//  ToolLanguageFilterItemDomainModelInterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/2/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol ToolLanguageFilterItemDomainModelInterface: Sendable, Identifiable {
    
    var languageId: String { get }
    var languageNameTranslatedInLanguage: String { get }
    var languageNameTranslatedInAppLanguage: String { get }
    var availableText: String? { get }
}

extension ToolLanguageFilterItemDomainModelInterface  {
    var id: String {
        return languageId
    }
}
