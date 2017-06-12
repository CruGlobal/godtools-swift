//
//  TractTab.swift
//  godtools
//
//  Created by Devserker on 5/12/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractTab: BaseTractElement {
    
    // MARK: - Positions and Sizes
    
    var xPosition: CGFloat {
        return 0.0
    }
    var yPosition: CGFloat {
        return self.yStartPosition
    }
    
    // MARK: - Setup
    
    var properties = TractTabProperties()
    
    override func loadFrameProperties() {
        self.elementFrame.x = self.xPosition
        self.elementFrame.y = self.yPosition
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
    }

}
