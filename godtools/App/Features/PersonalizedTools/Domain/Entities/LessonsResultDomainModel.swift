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
    let unavailableTitle: String?
    let unavailableMessage: String?

    static var empty: LessonsResultDomainModel {
        LessonsResultDomainModel(
            lessons: [],
            unavailableTitle: nil,
            unavailableMessage: nil
        )
    }
}
