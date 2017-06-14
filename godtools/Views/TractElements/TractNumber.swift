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
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractNumberProperties.self
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        super.setupView(properties: properties)
        
        if self.parent != nil && self.parent!.isKind(of: TractHeader.self) {
            (self.parent as! TractHeader).headerProperties().includesNumber = true
        }
    }
    
    override func textStyle() -> TractTextContentProperties {
        let textStyle = super.textStyle()
        textStyle.font = .gtThin(size: 54.0)
        textStyle.width = TractNumber.widthConstant
        textStyle.height = 60.0
        textStyle.textAlign = .center
        textStyle.textColor = .gtWhite
        return textStyle
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = TractNumber.marginConstant
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
    }

}
