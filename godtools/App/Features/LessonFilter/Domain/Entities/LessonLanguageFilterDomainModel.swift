//
//  LessonLanguageFilterDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct LessonLanguageFilterDomainModel {
    let languageId: String
    let languageName: String
    let translatedName: String
    let lessonsAvailableText: String
}

extension LessonLanguageFilterDomainModel: StringSearchable {
    
    var searchableStrings: [String] {
        return [languageName, translatedName]
    }
}

extension LessonLanguageFilterDomainModel: Identifiable {
    
    var id: String {
        return languageId
    }
}
