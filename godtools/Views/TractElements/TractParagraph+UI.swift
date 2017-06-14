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
        let textStyle = super.textStyle()
        textStyle.font = .gtRegular(size: 18.0)
        textStyle.width = self.width
        textStyle.xMargin = BaseTractElement.xMargin
        textStyle.textColor = .gtWhite
        textStyle.textAlign = .center
        
        return textStyle
    }
    
    func buildStandardParagraph() -> TractTextContentProperties {
        var xMargin = BaseTractElement.xMargin
        
        if BaseTractElement.isCardElement(self) {
            xMargin = TractCard.xPaddingConstant
        }
        
        let textStyle = super.textStyle()
        textStyle.font = .gtRegular(size: 18.0)
        textStyle.width = self.width
        textStyle.xMargin = xMargin
        textStyle.textColor = self.textColor
        
        return textStyle
    }
    
}
