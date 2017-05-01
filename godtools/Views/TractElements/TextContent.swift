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
    
    var label: GTLabel?
    
    override func setupView(properties: Dictionary<String, Any>) {
        let attributes = loadElementAttributes(properties: properties)
        let self.label = GTLabel(frame: createLabelFrameForHeight(self.height))
        let text: String = attributes.text
        let backgroundColor: UIColor = attributes.backgroundColor
        
        self.label.text = text
        self.label.numberOfLines = 0
        self.label.sizeToFit()
        self.label.backgroundColor = backgroundColor
        
        self.view = label
    }
    
    func setupLabel() {
        let labelStyle = configureLabelStyle()
        self.label?.gtStyle = labelStyle.style
        self.label?.lineBreakMode = .byWordWrapping
        
        if labelStyle.height == 0.0 {
            self.label?.numberOfLines = 0
            self.label?.sizeToFit()
            self.height = (self.label?.frame.height)!
        }
        else {
            self.height = labelStyle.height
        }
        
        self.label?.frame = createLabelFrameForHeight(self.height)
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yStartPosition + self.height + BaseTractElement.Standards.yPadding
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
            backgroundColor = UIColor.clear
        }
        
        return (text, backgroundColor!)
    }
    
    fileprivate func createLabelFrameForHeight(_ height: CGFloat) -> CGRect {
        return CGRect(x: BaseTractElement.Standards.xPadding,
                      y: self.yStartPosition + BaseTractElement.Standards.yPadding,
                      width: BaseTractElement.Standards.textContentWidth,
                      height: height)
    }
    
}
