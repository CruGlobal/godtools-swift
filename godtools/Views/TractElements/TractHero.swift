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
    
    // MARK: Positions constants
    
    static let width: CGFloat = 300
    
    // MARK: - Positions and Sizes
    
    override func yEndPosition() -> CGFloat {
        return self.properties.frame.y + self.height
    }
    
    // MARK: - Object properties
    
    var properties = TractHeroProperties()
    
    // MARK: - Setup
    
    override func loadFrameProperties() {
        self.elementFrame.x = (TractHero.width - TractHero.width) / CGFloat(2)
        self.elementFrame.y = self.yStartPosition + BaseTractElement.yMargin
        self.elementFrame.width = TractHero.width
        self.elementFrame.height = self.height
    }
        
}
