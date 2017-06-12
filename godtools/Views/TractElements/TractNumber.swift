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
    
    override var width: CGFloat {
        return TractNumber.widthConstant
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
    
    override func loadFrameProperties() {
        self.elementFrame.x = self.xPosition
        self.elementFrame.y = self.elementFrame.yOrigin
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
    }

}
