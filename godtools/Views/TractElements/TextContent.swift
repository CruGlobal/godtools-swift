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
    
    var xPosition: CGFloat {
        return BaseTractElement.Standards.xMargin
    }
    var yPosition: CGFloat {
        return self.yStartPosition + BaseTractElement.Standards.yMargin
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
        let attributes = loadElementAttributes(properties: properties)
        let text: String = attributes.text
        let backgroundColor: UIColor = attributes.backgroundColor
        let labelStyle = self.parent?.textStyle()
        
        let width = (labelStyle?.width)! > CGFloat(0) ? labelStyle?.width : BaseTractElement.Standards.textContentWidth
        self.label = GTLabel(frame: buildFrame(width!, self.height))
        self.label?.text = text
        self.label?.backgroundColor = backgroundColor
        self.label?.gtStyle = (labelStyle?.style)!
        self.label?.lineBreakMode = .byWordWrapping
        
        if labelStyle?.height == 0.0 {
            self.label?.numberOfLines = 0
            self.label?.sizeToFit()
            self.height = (self.label?.frame.height)!
        }
        else {
            self.height = (labelStyle?.height)!
        }
        
        self.label?.frame = buildFrame(width!, self.height)
        self.view = label
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height
    }
    
    override func textYPadding() -> CGFloat {
        return (self.parent?.textYPadding())!
    }
    
    // MARK: - TextContent Helpers
    
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
                backgroundColor = UIColor.gtRed
            case "black":
                backgroundColor = UIColor.gtBlack
            default:
                backgroundColor = UIColor.clear
            }
        }
        else {
            backgroundColor = UIColor.gray //clear
        }
        
        return (text, backgroundColor!)
    }
    
    fileprivate func buildFrame(_ width: CGFloat, _ height: CGFloat) -> CGRect {
        let parentDimensions = self.parent?.getDimensions()
        let width = (parentDimensions?.width)! - (BaseTractElement.Standards.xPadding * CGFloat(2))
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: width,
                      height: height)
    }
    
}
