//
//  TractHero.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TractHero: BaseTractElement {
    
    // MARK: - Object properties
    
    var properties = TractHeroProperties()
    
    // MARK: - Setup
    
    override func loadElementProperties(_ properties: [String: Any]) {
        self.properties.load(properties)
        self.properties.parentProperties = getParentProperties()
    }
    
    override func loadFrameProperties() {
        let width: CGFloat = 300
        self.elementFrame.x = (super.width - width) / CGFloat(2)
        self.elementFrame.width = width
        self.elementFrame.height = self.height
        self.elementFrame.yMarginTop = BaseTractElement.yMargin
    }
    
    override func getElementProperties() -> TractProperties {
        return self.properties
    }
        
}
