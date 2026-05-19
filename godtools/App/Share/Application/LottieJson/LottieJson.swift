//
//  LottieJson.swift
//  godtools
//
//  Created by Levi Eggert on 5/18/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

enum LottieJson: String {
    
    case tutorialLessons = "tutorial_lessons"
    case tutorialScreenShare = "tutorial_screenshare"
    case tutorialToolTip = "tutorial_tooltip"
    
    var fileName: String {
        return rawValue
    }
}
