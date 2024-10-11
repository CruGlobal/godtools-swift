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
    case inProgress(completionProgress: Double, progressString: String)
    case complete(completeString: String)
}

extension LessonListItemProgressDomainModel {
    var isHidden: Bool {
        switch self {
        case .hidden: return true
        default: return false
        }
    }
    
    var isComplete: Bool {
        switch self {
        case .complete: return true
        default: return false
        }
    }
}
