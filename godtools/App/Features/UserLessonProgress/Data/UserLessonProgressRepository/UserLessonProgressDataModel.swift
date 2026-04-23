//
//  UserLessonProgressDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 9/25/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct UserLessonProgressDataModel: Sendable {
    
    let id: String
    let lessonId: String
    let lastViewedPageId: String
    let progress: Double
}
