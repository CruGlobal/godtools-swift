//
//  PersonalizedLessonFilterLanguageDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/2/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct PersonalizedLessonFilterLanguageDomainModel: ToolLanguageFilterItemDomainModelInterface {
    
    let languageId: String
    let languageNamePair: TranslatedLanguageNamePairDomainModel
    
    var availableText: String? {
        return nil
    }
}
