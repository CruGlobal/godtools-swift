//
//  LessonFilterLanguageDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct LessonFilterLanguageDomainModel: ToolLanguageFilterItemDomainModelInterface {
    
    let languageId: String
    let languageNamePair: TranslatedLanguageNamePairDomainModel
    let lessonsAvailableText: String
    let lessonsAvailableCount: Int
    
    var availableText: String? {
        return lessonsAvailableText
    }
}
