//
//  TractCallToAction.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TractCallToAction: BaseTractElement {
    
    // MARK: Positions constants
    
    static let yMarginConstant: CGFloat = 8.0
    static let paddingConstant: CGFloat = 8.0
    static let minHeight: CGFloat = 80.0
    
    // MARK: - Positions and Sizes
    
    let buttonSizeConstant: CGFloat = 22.0
    let buttonSizeXMargin: CGFloat = 8.0
    var buttonXPosition: CGFloat {
        return self.elementFrame.finalWidth() - self.buttonSizeConstant - self.buttonSizeXMargin
    }
    
    override var height: CGFloat {
        get {
            return super.height > TractCallToAction.minHeight ? super.height : TractCallToAction.minHeight
        }
        set {
            super.height = newValue
        }
    }
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractCallToActionProperties.self
    }
    
    override func loadFrameProperties() {
        var yPosition: CGFloat {
            var position = self.elementFrame.y + TractCallToAction.yMarginConstant
            if position < (self.parent?.getMaxHeight())! - self.height {
                position = (self.parent?.getMaxHeight())! - self.height
            }
            return position
        }
        
        self.elementFrame.x = 0
        self.elementFrame.y = yPosition
        self.elementFrame.width = super.parent!.elementFrame.finalWidth()
        self.elementFrame.yMarginBottom = TractCallToAction.yMarginConstant
        self.elementFrame.xMargin = TractCallToAction.paddingConstant
    }
    
    override func loadStyles() {
        addArrowButton()
    }
    
    override func textStyle() -> TractTextContentProperties {
        let properties = super.textStyle()
        properties.width = self.elementFrame.finalWidth() - self.buttonSizeConstant - (self.buttonSizeXMargin * CGFloat(2))
        properties.xMargin = TractCallToAction.paddingConstant
        properties.yMargin = TractCallToAction.paddingConstant
        return properties
    }
    
    // MARK: - Helpers
    
    func callToActionProperties() -> TractCallToActionProperties {
        return self.properties as! TractCallToActionProperties
    }

}
