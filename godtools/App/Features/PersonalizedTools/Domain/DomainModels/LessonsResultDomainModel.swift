//
//  LessonsResultDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 3/4/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct LessonsResultDomainModel {

    let lessons: [LessonListItemDomainModel]
    let unavailableStrings: PersonalizedLessonsUnavailableDomainModel?

    static var empty: LessonsResultDomainModel {
        LessonsResultDomainModel(
            lessons: [],
            unavailableStrings: nil
        )
    }
}
