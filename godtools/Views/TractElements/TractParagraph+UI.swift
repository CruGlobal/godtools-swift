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
                return TractCard.xPaddingConstant
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
    
}
