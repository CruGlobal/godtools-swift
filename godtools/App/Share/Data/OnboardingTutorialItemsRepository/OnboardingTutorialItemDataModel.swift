//
//  OnboardingTutorialItemDataModel.swift
//  godtools
//
//  Created by Robert Eldredge on 10/11/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

struct OnboardingTutorialItemDataModel: TutorialItemType {
    
    let title: String
    let message: String
    let imageName: String?
    let animationName: String?
    let youTubeVideoId: String?
    let customViewId: String?
}
