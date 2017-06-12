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
    
    // MARK: - Positions and Sizes
    
    let marginConstant: CGFloat = 30.0
    
    // MARK: - Setup
    
    var properties = TractHeadingProperties()
    
    override func textStyle() -> TractTextContentProperties {
        let textStyle = super.textStyle()
        textStyle.font = .gtThin(size: 54.0)
        textStyle.color = self.primaryColor!
        return textStyle
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0.0
        self.elementFrame.y = self.elementFrame.yOrigin
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
        self.elementFrame.yMarginTop = self.marginConstant
    }

}
