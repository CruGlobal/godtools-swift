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
    var yPosition: CGFloat {
        return self.yStartPosition
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height
    }
    
    // MARK - Setup
    
    var properties = TractFormProperties()
    
    func loadFrameProperties() {
        self.properties.frame.x = self.xPosition
        self.properties.frame.y = self.yPosition
        self.properties.frame.width = self.width
        self.properties.frame.height = self.height
    }
    
    override func buildFrame() -> CGRect {
        return self.properties.frame.getFrame()
    }
    
}
