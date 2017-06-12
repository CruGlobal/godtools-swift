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
    
    var xPosition: CGFloat = 0.0
    
    var yPosition: CGFloat {
        return self.yStartPosition + self.marginConstant
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height
    }
    
    // MARK: - Setup
    
    var properties = TractHeadingProperties()
    
    override func textStyle() -> TractTextContentProperties {
        let textStyle = super.textStyle()
        textStyle.font = .gtThin(size: 54.0)
        textStyle.color = self.primaryColor!
        return textStyle
    }
    
    override func loadFrameProperties() {
        self.properties.frame.x = self.xPosition
        self.properties.frame.y = self.yPosition
        self.properties.frame.width = self.width
        self.properties.frame.height = self.height
    }

}
