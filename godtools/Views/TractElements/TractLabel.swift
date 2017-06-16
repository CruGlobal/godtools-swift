//
//  TractLabel.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash

class TractLabel: BaseTractElement {
    
    // MARK: - Object properties
    
    var tapView = UIView()
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractLabelProperties.self
    }
    
    override func loadElementProperties(_ properties: [String : Any]) {
        super.loadElementProperties(properties)
        self.properties.textColor = self.properties.primaryColor
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0.0
        self.elementFrame.width = self.parent!.elementFrame.width
        self.elementFrame.yMarginTop = 0.0
        self.elementFrame.xMargin = TractCard.xPaddingConstant
    }
    
    override func render() -> UIView {
        for element in self.elements! {
            self.addSubview(element.render())
        }
        
        if !BaseTractElement.isFormElement(self) {
            setupPressGestures()
            buildHorizontalLine()
        }
        
        TractBindings.addBindings(self)
        return self
    }
    
    override func textStyle() -> TractTextContentProperties {
        let properties = super.textStyle()
        properties.width = self.elementFrame.finalWidth()
        properties.xMargin = 0.0
        
        if BaseTractElement.isFormElement(self) {
            properties.font = .gtRegular(size: 16.0)
        } else {
            properties.font = .gtSemiBold(size: 18.0)
            properties.textColor = properties.primaryColor
        }
        
        return properties
    }
    
    // MARK: - Helpers
    
    func labelProperties() -> TractLabelProperties {
        return self.properties as! TractLabelProperties
    }

}
