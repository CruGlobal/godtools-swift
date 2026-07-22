//
//  UIViewController+AccessibilityScreenId.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addScreenAccessibility(screenAccessibility: AccessibilityStrings.Screen) {
        
        // Frame has to have a size, label can't be hidden, and alpha can't be zero in order to be queried. ~Levi
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        label.text = ""
        label.textColor = UIColor.clear
        label.clipsToBounds = true
        label.isHidden = false
        label.isUserInteractionEnabled = false
        label.accessibilityIdentifier = screenAccessibility.id
        
        view.insertSubview(label, at: 0)
    }
}
