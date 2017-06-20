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
        let width = self.elementFrame.finalWidth() - (TractButton.modalMarginConstant * 2.0)
        let height = properties.height
        self.button.designAsTractModalButton()
        self.button.frame = CGRect(x: TractButton.modalMarginConstant,
                                   y: TractButton.modalMarginConstant,
                                   width: width,
                                   height: height)
        
        
        self.height = height + TractButton.modalMarginConstant
        updateFrameHeight()
    }
    
    func configureAsStandardButton() {
        let properties = buttonProperties()
        let width = self.elementFrame.finalWidth() - (TractButton.standardMarginConstant * 2.0)
        let height = properties.height
        button.cornerRadius = properties.cornerRadius
        button.backgroundColor = properties.backgroundColor
        self.button.frame = CGRect(x: TractButton.standardMarginConstant,
                                   y: 0.0,
                                   width: width,
                                   height: height)
        
        self.height = height
        updateFrameHeight()
        
    }
    
}
