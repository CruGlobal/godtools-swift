//
//  TutorialItemType.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol TutorialItemType {
    
    var title: String { get }
    var message: String { get }
    var imageName: String? { get }
    var animationName: String? { get }
    var youTubeVideoId: String? { get }
    var customViewId: String? { get }
}
