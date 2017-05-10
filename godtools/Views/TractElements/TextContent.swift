//
//  TextContent.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TextContent: BaseTractElement {
    
    let xMargin: CGFloat = BaseTractElement.xMargin
    var xPosition: CGFloat = 0.0
    var yPosition: CGFloat = 0.0
    var contentWidth: CGFloat = 0.0
    override var width: CGFloat {
        return self.contentWidth - (self.xPosition * CGFloat(2))
    }
    override var height: CGFloat {
        get {
            return super.height + (textYPadding() * 2)
        }
        set {
            super.height = newValue
        }
    }
    
    var label: GTLabel?
    
    override func setupView(properties: Dictionary<String, Any>) {
        let labelStyle = self.parent?.textStyle()
        
        if (labelStyle?.width)! > CGFloat(0.0) {
            self.contentWidth = (labelStyle?.width)!
        } else {
            self.contentWidth = (self.parent?.width)!
        }
        
        self.xPosition = (labelStyle?.xMargin)!
        self.yPosition = self.yStartPosition + (labelStyle?.yMargin)!
        
        let attributes = loadElementAttributes(properties: properties)
        let text: String = attributes.text
        let backgroundColor: UIColor = attributes.backgroundColor
        
        self.label = GTLabel(frame: buildFrame())
        self.label?.text = text
        self.label?.textAlignment = (labelStyle?.alignment)!
        self.label?.backgroundColor = backgroundColor
        self.label?.gtStyle = (labelStyle?.style)!
        self.label?.textColor = labelStyle?.textColor
        self.label?.lineBreakMode = .byWordWrapping
        
        if labelStyle?.height == 0.0 {
            self.label?.numberOfLines = 0
            self.label?.sizeToFit()
            self.height = (self.label?.frame.height)!
        } else {
            self.height = (labelStyle?.height)!
        }
        
        self.frame = buildFrame()
        self.label?.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
        self.addSubview(self.label!)
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height
    }
    
    override func textYPadding() -> CGFloat {
        return (self.parent?.textYPadding())!
    }
    
    // MARK: - Helpers
    
    fileprivate func loadElementAttributes(properties: Dictionary<String, Any>) -> (text: String, backgroundColor: UIColor) {
        var text: String = ""
        var backgroundColor: UIColor?
        
        if properties["value"] != nil {
            text = properties["value"] as! String
        }
        
        if properties["backgroundColor"] != nil {
            let backgroundColorText = properties["backgroundColor"] as! String
            switch backgroundColorText {
            case "red":
                backgroundColor = .gtRed
            case "black":
                backgroundColor = .gtBlack
            default:
                backgroundColor = .clear
            }
        } else {
            backgroundColor = .clear
        }
        
        return (text, backgroundColor!)
    }
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: self.width,
                      height: self.height)
    }
    
}
