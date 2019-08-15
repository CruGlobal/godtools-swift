//
//  UINavigationController+GodTools.swift
//  godtools
//
//  Created by Dean Thibault on 8/15/19.
//  Copyright © 2019 Cru. All rights reserved.
//

import Foundation

extension UINavigationController {
    
    func handleLanguageSwitch() {
        navigationBar.semanticContentAttribute = UIView.appearance().semanticContentAttribute
        navigationBar.setNeedsLayout()
        navigationBar.layoutIfNeeded()
        navigationBar.setNeedsDisplay()
    }
}
