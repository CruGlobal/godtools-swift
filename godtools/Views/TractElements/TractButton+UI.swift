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
        self.height = self.properties.height + (TractButton.modalMarginConstant * CGFloat(2))
        self.button.designAsTractModalButton()
        self.frame = buildFrame()
        self.button.frame = CGRect(x: self.buttonXPosition,
                                   y: TractButton.modalMarginConstant,
                                   width: self.buttonWidth,
                                   height: self.properties.height)
    }
    
    func configureAsStandardButton() {
        self.height = self.properties.height
        button.cornerRadius = self.properties.cornerRadius
        button.backgroundColor = self.properties.backgroundColor
        self.frame = buildFrame()
        self.button.frame = CGRect(x: self.buttonXPosition,
                                   y: 0.0,
                                   width: self.buttonWidth,
                                   height: self.height)
        
    }
    
}
