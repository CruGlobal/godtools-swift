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
        
        let textField = UITextField(frame: .zero)
        textField.text = ""
        textField.isHidden = true
        textField.accessibilityIdentifier = screenAccessibility.id
        
        view.addSubview(textField)
    }
}
