//
//  LessonListItemProgressDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 10/4/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

enum LessonListItemProgressDomainModel {
    case hidden
    case inProgress(progress: Double, progressString: String)
    case complete(completeString: String)
}
