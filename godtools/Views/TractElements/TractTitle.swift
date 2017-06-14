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
        properties.textColor = .gtWhite
        
        if BaseTractElement.isModalElement(self) {
            properties.font = .gtThin(size: 54.0)
            properties.width = TractModal.contentWidth
            properties.textAlign = .center
        } else {
            properties.font = .gtThin(size: 18.0)
            properties.width = self.width
        }
        
        return properties
    }
    
    override func loadFrameProperties() {
        var xPosition: CGFloat {
            if (self.parent?.isKind(of: TractHeader.self))! && (self.parent as! TractHeader).headerProperties().includesNumber {
                return TractNumber.marginConstant + TractNumber.widthConstant + TractTitle.marginConstant
            } else if (BaseTractElement.isModalElement(self)) {
                return (self.parent!.width - TractModal.contentWidth) / CGFloat(2)
            } else {
                return TractTitle.marginConstant
            }
        }
        
        self.elementFrame.x = xPosition
        self.elementFrame.width = (self.parent?.width)! - xPosition - TractTitle.marginConstant
        self.elementFrame.height = self.height
    }
    
    // MARK: - Helpers
    
    func titleProperties() -> TractTitleProperties {
        return self.properties as! TractTitleProperties
    }

}
