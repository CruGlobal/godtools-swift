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
    
    override func setupView(properties: Dictionary<String, Any>) {
        let attributes = loadElementAttributes(properties: properties)
        let label = GTLabel(frame: createLabelFrameForHeight(self.height))
        let text: String = attributes.text
        let backgroundColor: UIColor = attributes.backgroundColor
        
        label.text = text
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.backgroundColor = backgroundColor
        
        if BaseTractElement.isParagraphElement(self) {
            label.gtStyle = "toolFrontSubTitle"
            label.numberOfLines = 0
            label.sizeToFit()
            self.height = label.frame.height
            label.frame = createLabelFrameForHeight(self.height)
        } else if BaseTractElement.isHeadingElement(self) {
            label.gtStyle = "toolFrontTitle"
            label.numberOfLines = 0
            label.sizeToFit()
            self.height = label.frame.height
            label.frame = createLabelFrameForHeight(self.height)
        }
        
        self.view = label
    }
    
    func loadElementAttributes(properties: Dictionary<String, Any>) -> (text: String, backgroundColor: UIColor) {
        var text: String = ""
        var backgroundColor: UIColor?
        
        if properties["text"] != nil {
            text = properties["text"] as! String
        }
        
        if properties["backgroundColor"] != nil {
            let backgroundColorText = properties["backgroundColor"] as! String
            switch backgroundColorText {
            case "red":
                backgroundColor = UIColor.gtRed
            case "black":
                backgroundColor = UIColor.gtBlack
            default:
                backgroundColor = UIColor.gtWhite
            }
        }
        else {
            backgroundColor = UIColor.gtWhite
        }
        
        return (text, backgroundColor!)
    }
    
    fileprivate func createLabelFrameForHeight(_ height: CGFloat) -> CGRect {
        return CGRect(x: BaseTractElement.Standards.xPadding,
                      y: self.yStartPosition,
                      width: BaseTractElement.Standards.textContentWidth,
                      height: height)
    }
    
}
