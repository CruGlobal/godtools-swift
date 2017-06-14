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
        let textStyle = super.textStyle()
        textStyle.font = .gtThin(size: 54.0)
        textStyle.textColor = self.primaryColor!
        return textStyle
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0.0
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
        self.elementFrame.yMarginTop = 30.0
    }

}
