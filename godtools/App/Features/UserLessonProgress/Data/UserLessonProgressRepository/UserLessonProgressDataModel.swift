//
//  UserLessonProgressDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 9/25/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct UserLessonProgressDataModel {
    
    let lessonId: String
    let progress: Double
}

extension UserLessonProgressDataModel {
    init(realmUserLessonProgress: RealmUserLessonProgress) {
        lessonId = realmUserLessonProgress.lessonId
        progress = realmUserLessonProgress.progress
    }
}
