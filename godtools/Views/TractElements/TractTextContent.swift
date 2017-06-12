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
    
    // MARK: - Object properties
    
    var properties = TractTextContentProperties()
    var label: GTLabel = GTLabel()
    
    // MARK: - Setup
    
    override func setupView(properties: [String: Any]) {
        super.setupView(properties: properties)
        buildLabel()
        
        self.frame = buildFrame()
        self.label.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
        
        self.addSubview(self.label)
    }
    
    override func loadStyles() {
        if self.properties.width > CGFloat(0.0) {
            self.contentWidth = self.properties.width
        } else {
            self.contentWidth = (self.parent?.width)!
        }
        
        self.xPosition = self.properties.xMargin
        self.yPosition = self.yStartPosition + self.properties.yMargin
    }
    
    func loadFrameProperties() {
        self.properties.frame.x = self.xPosition
        self.properties.frame.y = self.yPosition
        self.properties.frame.width = self.width
        self.properties.frame.height = self.height
    }
    
    override func buildFrame() -> CGRect {
        return self.properties.frame.getFrame()
    }
    
    override func loadElementProperties(_ properties: [String: Any]) {
        self.properties = (self.parent?.textStyle())!
        self.properties.load(properties)
    }
    
    // MARK: - UI
    
    private func buildLabel() {
        self.label = GTLabel(frame: buildFrame())
        self.label.text = self.properties.value
        self.label.textAlignment = self.properties.textAlign
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
    }
    
}
