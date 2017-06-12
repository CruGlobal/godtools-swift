//
//  TractForm.swift
//  godtools
//
//  Created by Devserker on 5/11/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractForm: BaseTractElement {
    
    // MARK: - Positions and Sizes
    
    var xPosition: CGFloat {
        return 0.0
    }
    
    // MARK - Setup
    
    var properties = TractFormProperties()
    
    override func loadFrameProperties() {
        self.elementFrame.x = self.xPosition
        self.elementFrame.y = self.elementFrame.yOrigin
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
    }
    
}
