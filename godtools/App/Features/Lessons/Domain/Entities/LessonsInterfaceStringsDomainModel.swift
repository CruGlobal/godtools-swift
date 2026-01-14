//
//  LessonsInterfaceStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct LessonsInterfaceStringsDomainModel {

    let title: String
    let subtitle: String
    let languageFilterTitle: String
    let personalizedToolToggleTitle: String
    let allLessonsToggleTitle: String
    let personalizedLessonFooterTitle: String
    let personalizedLessonFooterSubtitle: String
    let personalizedLessonFooterButtonTitle: String

    static var emptyValue: LessonsInterfaceStringsDomainModel {
        LessonsInterfaceStringsDomainModel(title: "", subtitle: "", languageFilterTitle: "", personalizedToolToggleTitle: "", allLessonsToggleTitle: "", personalizedLessonFooterTitle: "", personalizedLessonFooterSubtitle: "", personalizedLessonFooterButtonTitle: "")
    }
}
