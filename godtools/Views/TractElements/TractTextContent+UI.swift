//
//  TractTextContent+UI.swift
//  godtools
//
//  Created by Pablo Marti on 6/13/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractTextContent {
    
    func buildLabel() {
        if BaseTractElement.isNumberElement(self) {
            buildNumberLabel()
        } else {
            buildStandardLabel()
        }
        
        self.addSubview(self.label)
    }
    
    func buildStandardLabel() {
        let properties = textProperties()
        
        let originalFrame = getFrame()
        let labelFrame = CGRect(x: 0.0,
                                y: self.elementFrame.yMarginTop,
                                width: originalFrame.size.width,
                                height: 0.0)
        
        self.label = GTLabel(frame: labelFrame)
        self.label.text = properties.value
        self.label.textAlignment = properties.textAlign
        self.label.font = properties.font
        self.label.textColor = properties.textColor
        self.label.lineBreakMode = .byWordWrapping
        self.label.numberOfLines = 0
        self.label.sizeToFit()
        
        self.height = self.label.frame.size.height + self.elementFrame.yMarginBottom
    }
    
    func buildNumberLabel() {
        let properties = textProperties()
        
        let originalFrame = getFrame()
        let labelFrame = CGRect(x: 0.0,
                                y: self.elementFrame.yMarginTop,
                                width: originalFrame.size.width,
                                height: 60.0)
        
        self.label = GTLabel(frame: labelFrame)
        self.label.text = properties.value
        self.label.textAlignment = .center
        self.label.font = properties.font
        self.label.textColor = properties.textColor
        self.label.numberOfLines = 1
        
        self.height = self.label.frame.size.height + self.elementFrame.yMarginBottom
    }
    
}
