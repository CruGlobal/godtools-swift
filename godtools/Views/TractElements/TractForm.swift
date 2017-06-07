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
    
    // MARK: - Object properties
    
    var properties = TractFormProperties()
    
    // MARK - Setup
        
    override func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: self.width,
                      height: self.height)
    }
    
    // MARK: - Bindings
    
    override func elementListeners() -> [String]? {
        return self.properties.listeners == nil ? nil : self.properties.listeners?.components(separatedBy: " ")
    }
    
    // MARK: - Helpers
    
    override func loadElementProperties(_ properties: [String: Any]) {
        self.properties.load(properties)
    }
    
}
