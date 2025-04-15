//
//  LessonSwipeTutorialInterfaceStringsDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct LessonSwipeTutorialInterfaceStringsDomainModel {
    let title: String
    let closeButtonText: String
    
    static func emptyStrings() -> LessonSwipeTutorialInterfaceStringsDomainModel {
        return LessonSwipeTutorialInterfaceStringsDomainModel(title: "", closeButtonText: "")
    }
}
