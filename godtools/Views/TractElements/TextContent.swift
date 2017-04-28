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
    
    var textScale = CGFloat(1.0)
    var textColor = UIColor.black
    var text = ""
    
    override func setupView(properties: Dictionary<String, Any>) {
        let attributes = loadElementAttributes(properties: properties)
        let label = UILabel(frame: createLabelFrameForHeight(self.height))
        
        label.font = UIFont(name: "Helvetica", size: CGFloat(16.0) * textScale)
        label.text = attributes.text
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.backgroundColor = .yellow
        
        if BaseTractElement.isParagraphElement(self) {
            self.height = label.frame.size.height + CGFloat(20.0)
            label.frame = createLabelFrameForHeight(self.height)
        } else if BaseTractElement.isHeadingElement(self) {
            self.height = label.frame.size.height + CGFloat(30.0)
            label.frame = createLabelFrameForHeight(self.height)
        }
        
        self.view = label
    }
    
    func loadElementAttributes(properties: Dictionary<String, Any>) -> (text: String, color: UIColor) {
        let text: String = properties["text"] as! String
        let colorText: String = properties["color"] as! String
        var color: UIColor?
        
        switch colorText {
        case "red":
            color = UIColor.gtRed
        default:
            color = UIColor.gtBlack
        }
        
        return (text, color!)
    }
    
    fileprivate func createLabelFrameForHeight(_ height: CGFloat) -> CGRect {
        return CGRect(x: BaseTractElement.Standards.xPadding,
                      y: self.yStartPosition,
                      width: BaseTractElement.Standards.textContentWidth,
                      height: height)
    }
    
}
