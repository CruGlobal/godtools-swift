//
//  TractTab.swift
//  godtools
//
//  Created by Devserker on 5/12/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractTab: BaseTractElement {
    
    // MARK: Positions constants
    
    static let xMarginConstant: CGFloat = 0.0
    static let yMarginConstant: CGFloat = 8.0
    
    // MARK: - Object properties
    
    var analyticsTabDictionary: [String: String] = [:]
        
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractTabProperties.self
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0.0
        self.elementFrame.width = self.parentWidth()
        self.elementFrame.yMarginBottom = TractTab.yMarginConstant
    }
    
    // MARK: - Helpers
    
    func tabProperties() -> TractTabProperties {
        return self.properties as! TractTabProperties
    }

}
