//
//  TractParagraph+UI.swift
//  godtools
//
//  Created by Pablo Marti on 6/13/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractParagraph {
    
    func buildModalParagraph() -> TractTextContentProperties {
        let properties = super.textStyle()
        properties.font = .gtRegular(size: 18.0)
        properties.width = self.elementFrame.finalWidth()
        properties.xMargin = BaseTractElement.xMargin
        properties.textColor = .gtWhite
        properties.textAlign = .center
        return properties
    }
    
    func buildStandardParagraph() -> TractTextContentProperties {
        var xMargin: CGFloat{
            if BaseTractElement.isCardElement(self) {
                return 0.0
            } else {
                return BaseTractElement.xMargin
            }
        }
        
        let properties = super.textStyle()
        properties.width = self.elementFrame.finalWidth()
        properties.font = .gtRegular(size: 18.0)
        properties.xMargin = xMargin
        return properties
    }
    
    func buildStandardFrame() {
        var xMargin: CGFloat{
            if BaseTractElement.isCardElement(self) {
                return TractCard.xPaddingConstant
            } else {
                return TractParagraph.marginConstant
            }
        }
        
        self.elementFrame.x = 0
        self.elementFrame.width = parentWidth()
        self.elementFrame.yMarginTop = TractParagraph.marginConstant
        self.elementFrame.xMargin = xMargin
    }
    
    func buildModalFrame() {
        let width = TractModal.contentWidth
        self.elementFrame.x = (self.parent!.width - width) / CGFloat(2)
        self.elementFrame.width = width
        self.elementFrame.yMarginTop = TractParagraph.marginConstant
    }
    
}
