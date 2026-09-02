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
    let languageNameTranslatedInLanguage: String
    let languageNameTranslatedInAppLanguage: String
    
    var availableText: String? {
        return nil
    }
}
