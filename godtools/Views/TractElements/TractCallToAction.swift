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
    
    var xPosition: CGFloat {
        return TractCard.xMarginConstant
    }
    
    override var width: CGFloat {
        return (self.parent?.width)! - self.xPosition - TractCard.xMarginConstant
    }
    
    override var height: CGFloat {
        get {
            return super.height > TractCallToAction.minHeight ? super.height : TractCallToAction.minHeight
        }
        set {
            super.height = newValue
        }
    }
    
    var yPosition: CGFloat {
        var position = self.elementFrame.y + TractCallToAction.yMarginConstant
        if position < (self.parent?.getMaxHeight())! - self.height {
            position = (self.parent?.getMaxHeight())! - self.height
        }
        return position
    }
    
    let buttonSizeConstant: CGFloat = 22.0
    
    let buttonSizeXMargin: CGFloat = 8.0
    
    var buttonXPosition: CGFloat {
        return self.width - self.buttonSizeConstant - self.buttonSizeXMargin
    }
    
    override func textYPadding() -> CGFloat {
        return 15.0
    }
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractCallToActionProperties.self
    }
    
    override func loadStyles() {
        addArrowButton()
    }
    
    override func textStyle() -> TractTextContentProperties {
        let properties = super.textStyle()
        properties.width = self.width - self.buttonSizeConstant - (self.buttonSizeXMargin * CGFloat(2))
        properties.xMargin = TractCallToAction.paddingConstant
        properties.yMargin = TractCallToAction.paddingConstant
        return properties
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = self.xPosition
        self.elementFrame.y = self.yPosition
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
        self.elementFrame.yMarginBottom = TractCallToAction.yMarginConstant
    }
    
    // MARK: - Helpers
    
    func callToActionProperties() -> TractCallToActionProperties {
        return self.properties as! TractCallToActionProperties
    }

}
