//
//  TractHeader.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TractHeader: BaseTractElement {
    
    // MARK: - Setup
    
    var properties = TractHeaderProperties()
    
    override func loadStyles() {
        self.backgroundColor = self.manifestProperties.primaryColor.withAlphaComponent(0.9)
    }
    
    override func loadElementProperties(_ properties: [String: Any]) {
        self.properties.load(properties)
        self.properties.parentProperties = getParentProperties()
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0.0
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
        self.elementFrame.yMarginTop = 1.0
        self.elementFrame.yMarginBottom = 10.0
    }
    
    override func getElementProperties() -> TractProperties {
        return self.properties
    }
    
    override var horizontalContainer: Bool {
        return true
    }

}
