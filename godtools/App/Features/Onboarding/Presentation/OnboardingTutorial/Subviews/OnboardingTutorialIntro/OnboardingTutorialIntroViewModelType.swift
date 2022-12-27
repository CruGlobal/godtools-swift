//
//  OnboardingTutorialIntroViewModelType.swift
//  godtools
//
//  Created by Robert Eldredge on 9/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import UIKit

protocol OnboardingTutorialIntroViewModelType {
    
    var logoImage: UIImage? { get }
    var title: String { get }
    var videoLinkLabel: String { get }
    
    func videoLinkTapped()
}
