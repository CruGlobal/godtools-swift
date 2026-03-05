//
//  LessonsStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct LessonsStringsDomainModel: Sendable {

    let title: String
    let subtitle: String
    let languageFilterTitle: String
    let personalizedToolToggleTitle: String
    let allLessonsToggleTitle: String
    let personalizedLessonExplanationTitle: String
    let personalizedLessonExplanationSubtitle: String
    let changeSettings: String
    let viewAllLessons: String

    static var emptyValue: LessonsStringsDomainModel {
        LessonsStringsDomainModel(title: "", subtitle: "", languageFilterTitle: "", personalizedToolToggleTitle: "", allLessonsToggleTitle: "", personalizedLessonExplanationTitle: "", personalizedLessonExplanationSubtitle: "", changeSettings: "", viewAllLessons: "")
    }
}
