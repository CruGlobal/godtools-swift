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
    
    override func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: self.width,
                      height: self.height)
    }

}
