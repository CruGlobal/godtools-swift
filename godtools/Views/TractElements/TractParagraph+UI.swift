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
        properties.width = self.width
        properties.xMargin = BaseTractElement.xMargin
        properties.textColor = .gtWhite
        properties.textAlign = .center
        return properties
    }
    
    func buildStandardParagraph() -> TractTextContentProperties {
        var xMargin = BaseTractElement.xMargin
        
        if BaseTractElement.isCardElement(self) {
            xMargin = TractCard.xPaddingConstant
        }
        
        let properties = super.textStyle()
        properties.font = .gtRegular(size: 18.0)
        properties.xMargin = xMargin
        return properties
    }
    
}
