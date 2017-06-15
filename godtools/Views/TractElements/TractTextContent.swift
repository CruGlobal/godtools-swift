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
    
    override func textYPadding() -> CGFloat {
        return (self.parent?.textYPadding())!
    }
    
    // MARK: - Object properties
    
    var label: GTLabel = GTLabel()
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractTextContentProperties.self
    }
    
    override func setupView(properties: [String: Any]) {
        super.setupView(properties: properties)
        buildLabel()
        
        updateFrameHeight()
        self.label.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
        
        self.addSubview(self.label)
    }
    
    override func loadStyles() {
        let properties = textProperties()
        
        if properties.width > CGFloat(0.0) {
            self.contentWidth = properties.width
        } else {
            self.contentWidth = (self.parent?.width)!
        }
    }
    
    override func loadElementProperties(_ properties: [String: Any]) {
        var textProperties = TractTextContentProperties()
        textProperties.setupDefaultProperties(properties: getParentProperties())
        textProperties = self.parent!.textStyle()
        textProperties.load(properties)
        self.properties = textProperties
    }
    
    override func loadFrameProperties() {
        let properties = textProperties()
        
        self.elementFrame.x = properties.xMargin
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
        self.elementFrame.yMarginTop = properties.yMargin
    }
    
    // MARK: - Helpers
    
    func textProperties() -> TractTextContentProperties {
        return self.properties as! TractTextContentProperties
    }
    
}
