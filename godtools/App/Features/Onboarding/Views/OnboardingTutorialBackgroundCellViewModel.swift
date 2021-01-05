//
//  OnboardingTutorialBackgroundCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class OnboardingTutorialBackgroundCellViewModel {
    
    enum BackgroundCustomViewId: String {
        case gradientBackground = "onboarding_tutorial_gradient_background"
    }
    
    let backgroundImage: UIImage?
    let backgroundView: UIView?
    
    required init(item: OnboardingTutorialItem) {
        
        if let name = item.backgroundImageName {
            backgroundImage = UIImage(named: name)
        }
        else {
            backgroundImage = nil
        }
        
        let backgroundViewId: BackgroundCustomViewId? = BackgroundCustomViewId(rawValue: item.backgroundCustomViewId ?? "")
        if let backgroundViewId = backgroundViewId {
            switch backgroundViewId {
            case .gradientBackground:
                backgroundView = OnboardingTutorialGradientBackgroundView()
            }
        }
        else {
            backgroundView = nil
        }
    }
}
