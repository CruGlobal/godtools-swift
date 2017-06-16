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
    
    // MARK: - Object properties
    
    var label: GTLabel = GTLabel()
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractTextContentProperties.self
    }
    
    override func loadElementProperties(_ properties: [String: Any]) {
        let textProperties = self.parent!.textStyle()
        textProperties.setupDefaultProperties(properties: getParentProperties())
        textProperties.load(properties)
        self.properties = textProperties
    }
    
    override func loadFrameProperties() {
        let properties = textProperties()
        self.elementFrame.width = properties.width
        self.elementFrame.xMargin = properties.xMargin
        self.elementFrame.yMarginTop = properties.yMargin
        self.elementFrame.yMarginBottom = properties.yMargin
    }
    
    override func setupView(properties: [String: Any]) {
        buildLabel()
        updateFrameHeight()
        // self.backgroundColor = .blue
    }
    
    // MARK: - Helpers
    
    func textProperties() -> TractTextContentProperties {
        return self.properties as! TractTextContentProperties
    }
    
}
