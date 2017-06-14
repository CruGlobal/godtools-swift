//
//  TractTab.swift
//  godtools
//
//  Created by Devserker on 5/12/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractTab: BaseTractElement {
        
    // MARK: - Setup
    
    var properties = TractTabProperties()
    
    override func loadElementProperties(_ properties: [String: Any]) {
        self.properties.load(properties)
        self.properties.parentProperties = getParentProperties()
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0.0
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
    }
    
    override func getElementProperties() -> TractProperties {
        return self.properties
    }

}
