//
//  UserLessonProgressDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 10/21/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct UserLessonProgressDomainModel: Sendable {
    
    let lessonId: String
    let lastViewedPageId: String
    let progress: Double
}
