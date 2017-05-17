//
//  TractTextContent.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TractTextContent: BaseTractElement {
    
    // MARK: - Object configurations
    
    var properties = TractTextContentProperties()
    var label: GTLabel = GTLabel()
    
    // MARK: - Positions and Sizes
    
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
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height
    }
    
    override func textYPadding() -> CGFloat {
        return (self.parent?.textYPadding())!
    }
    
    // MARK: - Setup
    
    override func setupView(properties: [String: Any]) {
        loadStyles()
        loadElementProperties(properties: properties)
        
        self.label = GTLabel(frame: buildFrame())
        self.label.text = self.properties.value
        self.label.textAlignment = self.properties.align
        self.label.font = self.properties.font
        self.label.textColor = self.properties.color
        self.label.lineBreakMode = .byWordWrapping
        
        if self.properties.height == 0.0 {
            self.label.numberOfLines = 0
            self.label.sizeToFit()
            self.height = self.label.frame.height
        } else {
            self.height = self.properties.height
        }
        
        self.frame = buildFrame()
        self.label.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
        
        self.addSubview(self.label)
    }
    
    // MARK: - Helpers
    
    func loadStyles() {
        self.properties = (self.parent?.textStyle())!
        
        if self.properties.width > CGFloat(0.0) {
            self.contentWidth = self.properties.width
        } else {
            self.contentWidth = (self.parent?.width)!
        }
        
        self.xPosition = self.properties.xMargin
        self.yPosition = self.yStartPosition + self.properties.yMargin
    }
    
    func loadElementProperties(properties: [String: Any]) {
        for property in properties.keys {
            switch property {
            case "value":
                self.properties.value = properties[property] as! String?
            case "i18n-id":
                self.properties.i18nId = properties[property] as! String?
            case "text-color":
                self.properties.color = ((properties[property] as! String?)?.getRGBAColor())!
            case "text-scale":
                self.properties.scale = properties[property] as! CGFloat?
            case "text-align":
                self.properties.align = (properties[property] as! NSTextAlignment?)!
            default: break
            }
        }
    }
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: self.width,
                      height: self.height)
    }
    
}
