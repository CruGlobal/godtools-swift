//
//  LessonCompletionDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 9/25/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct LessonCompletionDataModel {
    
    let lessonId: String
    let progress: Double
}

extension LessonCompletionDataModel {
    init(realmLessonCompletion: RealmLessonCompletion) {
        lessonId = realmLessonCompletion.lessonId
        progress = realmLessonCompletion.progress
    }
}
