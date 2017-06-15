//
//  TractButton+UI.swift
//  godtools
//
//  Created by Pablo Marti on 6/13/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractButton {
    
    func configureAsModalButton() {
        let properties = buttonProperties()
        self.height = properties.height + (TractButton.modalMarginConstant * CGFloat(2))
        self.button.designAsTractModalButton()
        updateFrameHeight()
        self.button.frame = CGRect(x: self.buttonXPosition,
                                   y: TractButton.modalMarginConstant,
                                   width: self.buttonWidth,
                                   height: properties.height)
    }
    
    func configureAsStandardButton() {
        let properties = buttonProperties()
        self.height = properties.height
        button.cornerRadius = properties.cornerRadius
        button.backgroundColor = properties.backgroundColor
        updateFrameHeight()
        self.button.frame = CGRect(x: self.buttonXPosition,
                                   y: 0.0,
                                   width: self.buttonWidth,
                                   height: self.height)
        
    }
    
}
