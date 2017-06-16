//
//  TractHeading.swift
//  godtools
//
//  Created by Devserker on 4/27/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TractHeading: BaseTractElement {
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractHeadingProperties.self
    }
    
    override func textStyle() -> TractTextContentProperties {
        let properties = super.textStyle()
        properties.font = .gtThin(size: 54.0)
        return properties
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0.0
        self.elementFrame.width = parentWidth()
        self.elementFrame.yMarginTop = 30.0
    }
    
    // MARK: - Helpers
    
    func headingProperties() -> TractHeadingProperties {
        return self.properties as! TractHeadingProperties
    }

}
