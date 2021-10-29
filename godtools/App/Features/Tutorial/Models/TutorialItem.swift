//
//  TutorialItem.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct TutorialItem: TutorialItemType {
    
    let title: String
    let message: String
    let imageName: String?
    let animationName: String?
    let youTubeVideoId: String?
    let customViewId: String?
}
