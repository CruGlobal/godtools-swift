//
//  TractHero.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TractHero: BaseTractElement {
    
    // MARK: - Positions and Sizes
    
    override var width: CGFloat {
        return 300
    }
    
    var xPosition: CGFloat {
        return (super.width - self.width) / CGFloat(2)
    }
    
    var yPosition: CGFloat {
        return self.yStartPosition + BaseTractElement.yMargin
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height
    }
    
    // MARK: - Object properties
    
    var properties = TractHeroProperties()
    
    // MARK: - Setup
    
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
