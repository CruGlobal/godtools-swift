//
//  TractNumber.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TractNumber: BaseTractElement {
    
    // MARK: Positions constants
    
    static let widthConstant: CGFloat = 70.0
    static let marginConstant: CGFloat = 8.0
    
    // MARK: - Positions and Sizes
    
    var xPosition: CGFloat {
        return TractNumber.marginConstant
    }
    
    var yPosition: CGFloat {
        return self.yStartPosition
    }
    
    override var width: CGFloat {
        return TractNumber.widthConstant
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height
    }
    
    // MARK: - Setup
    
    var properties = TractNumberProperties()
    
    override func setupView(properties: Dictionary<String, Any>) {
        super.setupView(properties: properties)
        
        if self.parent != nil && self.parent!.isKind(of: TractHeader.self) {
            (self.parent as! TractHeader).properties.includesNumber = true
        }
    }
    
    override func textStyle() -> TractTextContentProperties {
        let textStyle = super.textStyle()
        textStyle.font = .gtThin(size: 54.0)
        textStyle.width = self.width
        textStyle.height = 60.0
        textStyle.textAlign = .center
        textStyle.color = .gtWhite
        return textStyle
    }
    
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
