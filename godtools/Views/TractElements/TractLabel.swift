//
//  TractLabel.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash

class TractLabel: BaseTractElement {
    
    // MARK: Positions constants
    
    static let xMarginConstant: CGFloat = 0.0
    static let yMarginConstant: CGFloat = 0.0
    
    // MARK: - Positions and Sizes
    
    override var width: CGFloat {
        return (self.parent?.width)! - TractLabel.xMarginConstant - TractLabel.xMarginConstant
    }
    
    override func textYPadding() -> CGFloat {
        var padding: CGFloat = 15.0
        if BaseTractElement.isFormElement(self) {
            padding = 0.0
        }
        
        return padding
    }
    
    // MARK: - Object properties
    
    var tapView = UIView()
    
    // MARK: - Setup
    
    var properties = TractLabelProperties()
    
    override func textStyle() -> TractTextContentProperties {
        let textStyle = super.textStyle()
        textStyle.width = self.width
        textStyle.xMargin = TractCard.xPaddingConstant
        
        if BaseTractElement.isFormElement(self) {
            textStyle.font = .gtRegular(size: 16.0)
            textStyle.textColor = self.textColor
            textStyle.xMargin = CGFloat(0.0)
            textStyle.yMargin = CGFloat(0.0)
            textStyle.height = CGFloat(22.0)
        } else {
            textStyle.font = .gtSemiBold(size: 18.0)
            textStyle.color = self.primaryColor!
        }
        
        return textStyle
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = TractLabel.xMarginConstant
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
        self.elementFrame.yMarginTop = TractLabel.yMarginConstant
    }
    
    override func render() -> UIView {
        for element in self.elements! {
            self.addSubview(element.render())
        }
        
        if !BaseTractElement.isFormElement(self) {
            setupPressGestures()
            buildHorizontalLine()
        }
        
        TractBindings.addBindings(self)
        return self
    }

}
