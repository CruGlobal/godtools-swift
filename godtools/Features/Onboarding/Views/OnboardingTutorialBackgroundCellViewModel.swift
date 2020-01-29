//
//  OnboardingTutorialBackgroundCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class OnboardingTutorialBackgroundCellViewModel {
    
    let backgroundImage: UIImage?
    
    required init(item: OnboardingTutorialItem) {
        
        if let name = item.backgroundImageName {
            backgroundImage = UIImage(named: name)
        }
        else {
            backgroundImage = nil
        }
    }
}
