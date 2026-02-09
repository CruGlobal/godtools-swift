//
//  LessonSwipeTutorialStringsDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct LessonSwipeTutorialStringsDomainModel {
    
    let title: String
    let closeButtonText: String
    
    static var emptyValue: LessonSwipeTutorialStringsDomainModel {
        return LessonSwipeTutorialStringsDomainModel(title: "", closeButtonText: "")
    }
}
