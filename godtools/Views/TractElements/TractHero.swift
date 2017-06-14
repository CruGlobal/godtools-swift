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
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractHeroProperties.self
    }
    
    override func loadFrameProperties() {
        let width: CGFloat = 300
        self.elementFrame.x = (super.width - width) / CGFloat(2)
        self.elementFrame.width = width
        self.elementFrame.height = self.height
        self.elementFrame.yMarginTop = BaseTractElement.yMargin
    }
        
}
