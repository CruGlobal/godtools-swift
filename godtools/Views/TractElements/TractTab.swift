//
//  TractTab.swift
//  godtools
//
//  Created by Devserker on 5/12/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractTab: BaseTractElement {
        
    // MARK: - Setup
    
    var properties = TractTabProperties()
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0.0
        self.elementFrame.y = self.elementFrame.yOrigin
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
    }

}
