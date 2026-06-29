//
//  LessonFlowCompletedState.swift
//  godtools
//
//  Created by Levi Eggert on 7/27/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

enum LessonFlowCompletedState {
    
    case userClosedLesson(lessonId: String, lessonLanguage: AppLanguageDomainModel, highestPageNumberViewed: Int)
}
