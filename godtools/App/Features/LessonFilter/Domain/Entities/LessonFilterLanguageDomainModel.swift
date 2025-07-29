//
//  LessonFilterLanguageDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct LessonFilterLanguageDomainModel {
    let languageId: String
    let languageNameTranslatedInLanguage: String
    let languageNameTranslatedInAppLanguage: String
    let lessonsAvailableText: String
}

extension LessonFilterLanguageDomainModel: StringSearchable {
    
    var searchableStrings: [String] {
        return [languageNameTranslatedInLanguage, languageNameTranslatedInAppLanguage]
    }
}

extension LessonFilterLanguageDomainModel: Identifiable {
    
    var id: String {
        return languageId
    }
}
