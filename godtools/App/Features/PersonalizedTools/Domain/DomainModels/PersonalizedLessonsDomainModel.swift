//
//  PersonalizedLessonsDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 3/4/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct PersonalizedLessonsDomainModel: Sendable {

    let lessons: [LessonListItemDomainModel]
    let unavailableStrings: PersonalizedLessonsUnavailableDomainModel?

    static var emptyValue: PersonalizedLessonsDomainModel {
        PersonalizedLessonsDomainModel(
            lessons: [],
            unavailableStrings: nil
        )
    }
}
