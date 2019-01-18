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
        
        if let tractConfigurations = tractConfigurations, let language = tractConfigurations.language {
            let alignment = properties.textAlign
            label.textAlignment = alignment
            
            /* When the language that this label belongs to is rendered right to left, the text alignment
             needs to be inverted. label.textAlignment has already taken into account the renderer's default
             of "start" and a possible overriding value of "center" or "end" set by the text-align attribute.
             
             Up to this point we are assuming that textAlignment is set correctly and that the language is left to right.
             If we find out here the language is right to left, we simply need to invert the value. left becomes right
             and vice versa.*/
            if language.isRightToLeft() {
                switch alignment {
                case .left:
                    label.textAlignment = .right
                case .right:
                    label.textAlignment = .left
                default:
                    label.textAlignment = alignment
                }
            }
            self.label.font = properties.scaledFont(language: language)
        }
        
        if let page = page {
            self.label.textColor = properties.colorFor(self, pageProperties: page.pageProperties())
        }
        
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
            let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
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
