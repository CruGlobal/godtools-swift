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
        
        self.label = GTLabel(frame: properties.getFrame())
        self.label.text = properties.value
        self.label.textAlignment = properties.textAlign
        self.label.font = properties.scaledFont(language: self.tractConfigurations!.language!)
        self.label.textColor = properties.colorFor(self, pageProperties: page!.pageProperties())
        
        if properties.bold && properties.italic {
            self.label.font = self.label.font.setBoldItalic()
        } else {
            if properties.bold {
                self.label.font = self.label.font.setBold()
            }
            
            if properties.italic {
                self.label.font = self.label.font.setItalic()
            }
        }
        
        if properties.underline {
            let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
            let underlineAttributedString = NSAttributedString(string: properties.value, attributes: underlineAttribute)
            self.label.attributedText = underlineAttributedString
        }
        
        if properties.height == 0 {
            self.label.lineBreakMode = .byWordWrapping
            self.label.numberOfLines = 0
            self.label.sizeToFit()
            properties.height = self.label.frame.size.height
            self.label.frame = properties.getFrame()
        }
        
        self.height = properties.finalHeight
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
        self.label.font = properties.scaledFont(language: self.tractConfigurations!.language!)
        self.label.textColor = properties.colorFor(self, pageProperties: page!.pageProperties())
        self.label.numberOfLines = 1
        
        self.height = self.label.frame.size.height + self.elementFrame.yMarginBottom
    }

}
