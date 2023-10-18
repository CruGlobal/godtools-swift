//
//  AppNavigationBarAppearance.swift
//  godtools
//
//  Created by Levi Eggert on 10/16/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import UIKit

class AppNavigationBarAppearance {
    
    let backgroundColor: UIColor
    let controlColor: UIColor?
    let titleFont: UIFont?
    let titleColor: UIColor?
    let isTranslucent: Bool
    
    init(backgroundColor: UIColor, controlColor: UIColor?, titleFont: UIFont?, titleColor: UIColor?, isTranslucent: Bool) {
        
        self.backgroundColor = backgroundColor
        self.controlColor = controlColor
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.isTranslucent = isTranslucent
    }
}
