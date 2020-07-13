//
//  TractTextContent.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractTextContent: BaseTractElement {
    
    // MARK: Positions constants
    
    static let xTextMargin: CGFloat = 8.0
    static let yTextMargin: CGFloat = 0.0
    
    // MARK: - Object properties
    
    var label: GTLabel = GTLabel()
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractTextContentProperties.self
    }
    
    override func loadElementProperties(_ properties: [String: Any]) {
        let textProperties = self.parent!.textStyle()
        textProperties.setupParentProperties(properties: getParentProperties())
        textProperties.load(properties)
        self.properties = textProperties
    }
    
    override func loadFrameProperties() {
        let properties = textProperties()
        if properties.width == 0 {
            properties.width = parentWidth()
        }
        if let parent = parent as? TractCallToAction, isPrimaryRightToLeft {
            elementFrame.xMargin = parent.buttonSizeConstant
        }
        
        self.elementFrame.width = properties.width
    }
    
    override func setupView(properties: [String: Any]) {
        buildLabel()
        updateFrameHeight()
    }
    
    // MARK: - Helpers
    
    func textProperties() -> TractTextContentProperties {
        return self.properties as! TractTextContentProperties
    }
}

// MARK: - UI

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
            if LanguageDirection.direction(language: language) == .rightToLeft {
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
