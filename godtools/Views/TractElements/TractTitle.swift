//
//  TractTitle.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TractTitle: BaseTractElement {
    
    // MARK: Positions constants
    
    static let marginConstant: CGFloat = 8.0
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractTitleProperties.self
    }
    
    override func textStyle() -> TractTextContentProperties {
        let properties = super.textStyle()
        properties.yMargin = BaseTractElement.yMargin
        
        if BaseTractElement.isModalElement(self) {
            properties.font = .gtThin(size: 54.0)
            properties.width = TractModal.contentWidth
            properties.textAlign = .center
        } else {
            properties.font = .gtThin(size: 18.0)
        }
        
        return properties
    }
    
    override func loadFrameProperties() {
        var width = self.parent!.elementFrame.finalWidth()
        var xMarginLeft: CGFloat = TractTitle.marginConstant
        var xMarginRight: CGFloat = TractTitle.marginConstant
        var xPosition: CGFloat {
            if (self.parent?.isKind(of: TractHeader.self))! && (self.parent as! TractHeader).headerProperties().includesNumber {
                let difference =  TractNumber.marginConstant + TractNumber.widthConstant
                width -= difference
                return difference
            } else if (BaseTractElement.isModalElement(self)) {
                xMarginLeft = 0.0
                xMarginRight = 0.0
                return (width - TractModal.contentWidth) / CGFloat(2)
            } else {
                return 0
            }
        }
        
        self.elementFrame.x = xPosition
        self.elementFrame.width = width
        self.elementFrame.xMarginLeft = xMarginLeft
        self.elementFrame.xMarginRight = xMarginRight
    }
    
    // MARK: - Helpers
    
    func titleProperties() -> TractTitleProperties {
        return self.properties as! TractTitleProperties
    }

}
