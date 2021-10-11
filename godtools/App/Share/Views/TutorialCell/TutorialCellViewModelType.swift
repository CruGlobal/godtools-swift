//
//  TutorialCellViewModelType.swift
//  godtools
//
//  Created by Robert Eldredge on 10/11/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol TutorialCellViewModelType {
    
    var title: String { get }
    var message: String { get }
    var mainImageName: String? { get }
    var youTubeVideoId: String? { get }
    var animationName: String? { get }
    var customView: UIView? { get }
}
