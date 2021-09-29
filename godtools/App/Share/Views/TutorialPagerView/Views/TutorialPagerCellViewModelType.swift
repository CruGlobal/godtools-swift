//
//  TutorialPagerCellViewModelType.swift
//  godtools
//
//  Created by Robert Eldredge on 9/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol TutorialPagerCellViewModelType {
    
    var title: String { get }
    var message: String { get }
    var mainImageName: String? { get }
    var animationName: String? { get }
    var customView: UIView? { get }
    var hideSkip: Bool { get }
    var hideFooter: Bool { get }
}
