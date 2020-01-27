//
//  MainOnboardingTutorialCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MainOnboardingTutorialCellViewModel {
    
    let mainImage: UIImage?
    let title: String
    let message: String
    
    required init(item: MainOnboardingTutorialItem) {
        
        mainImage = UIImage(named: item.imageName)
        title = item.title
        message = item.message
    }
}
