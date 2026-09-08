//
//  PersonalizedToolFilterLanguageDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/3/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct PersonalizedToolFilterLanguageDomainModel: ToolLanguageFilterItemDomainModelInterface {
    
    let id: String
    let languageId: String
    let languageNamePair: TranslatedLanguageNamePairDomainModel
    
    var filterLanguageId: String? {
        return languageId
    }
    
    var availableText: String? {
        return nil
    }
}
