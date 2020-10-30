//
//  MainOnboardingTutorialCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MainOnboardingTutorialCellViewModel {
    
    let title: String
    let message: String
    let mainImageName: String?
    let animationName: String?
   
    required init(item: MainOnboardingTutorialItem) {
        title = item.title
        message = item.message
        mainImageName = item.imageName
        animationName = item.animationName
    }
}
