//
//  TractParagraph.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TractParagraph: BaseTractElement {
    
    static let marginConstant: CGFloat = 8.0
    
    var xPosition: CGFloat {
        return CGFloat(0.0)
    }
    var yPosition: CGFloat {
        return self.yStartPosition + TractParagraph.marginConstant
    }
    override var width: CGFloat {
        return (self.parent?.width)! - (self.xPosition * CGFloat(2))
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        self.frame = buildFrame()
    }
    
    override func textStyle() -> TractTextContentProperties {
        let textStyle = super.textStyle()
        
        var xMargin = BaseTractElement.xMargin
        if BaseTractElement.isCardElement(self) {
            xMargin = TractCard.xPaddingConstant
        }
        
        textStyle.font = .gtRegular(size: 18.0)
        textStyle.width = self.width
        textStyle.xMargin = xMargin
        textStyle.color = self.textColor
        
        return textStyle
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height
    }
    
    // MARK: - Helpers
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: self.width,
                      height: self.height)
    }
    
}
