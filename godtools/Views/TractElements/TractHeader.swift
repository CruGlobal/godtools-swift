//
//  TractHeader.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TractHeader: BaseTractElement {
    
    // MARK: - Positions and Sizes
    
    var xPosition: CGFloat {
        return 0.0
    }
    
    override var height: CGFloat {
        get {
            return super.height + 10.0
        }
        set {
            super.height = newValue
        }
    }
    
    // MARK: - Setup
    
    var properties = TractHeaderProperties()
    
    override func loadStyles() {
        self.backgroundColor = self.primaryColor?.withAlphaComponent(0.9)
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = self.xPosition
        self.elementFrame.y = self.elementFrame.yOrigin + 1.0
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
    }
    
    override var horizontalContainer: Bool {
        return true
    }

}
