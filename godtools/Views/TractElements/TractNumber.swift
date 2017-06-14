//
//  TractNumber.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TractNumber: BaseTractElement {
    
    // MARK: Positions constants
    
    static let widthConstant: CGFloat = 70.0
    static let marginConstant: CGFloat = 8.0
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractNumberProperties.self
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        super.setupView(properties: properties)
        
        if self.parent != nil && self.parent!.isKind(of: TractHeader.self) {
            (self.parent as! TractHeader).headerProperties().includesNumber = true
        }
    }
    
    override func textStyle() -> TractTextContentProperties {
        let properties = super.textStyle()
        properties.font = .gtThin(size: 54.0)
        properties.width = TractNumber.widthConstant
        properties.height = 60.0
        properties.textAlign = .center
        properties.textColor = .gtWhite
        return properties
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = TractNumber.marginConstant
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
    }
    
    // MARK: - Helpers
    
    func numberProperties() -> TractNumberProperties {
        return self.properties as! TractNumberProperties
    }

}
