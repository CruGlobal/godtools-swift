//
//  LessonListItemProgressDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 10/4/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct LessonListItemProgressDomainModel {
    
    let shouldShowLessonProgress: Bool
    let completionProgress: Double
    let progressString: String
}

extension LessonListItemProgressDomainModel {
    static func hiddenProgessDomainModel() -> LessonListItemProgressDomainModel {
        return LessonListItemProgressDomainModel(shouldShowLessonProgress: false, completionProgress: 0, progressString: "")
    }
}
