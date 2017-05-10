//
//  Paragraph.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class Paragraph: BaseTractElement {
    
    static let marginConstant: CGFloat = 8.0
    
    var xPosition: CGFloat {
        return CGFloat(0.0)
    }
    var yPosition: CGFloat {
        return self.yStartPosition + Paragraph.marginConstant
    }
    override var width: CGFloat {
        return (self.parent?.width)! - (self.xPosition * CGFloat(2))
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        self.frame = buildFrame()
    }
    
    override func textStyle() -> (style: String, width: CGFloat, height: CGFloat, alignment: NSTextAlignment, xMargin: CGFloat, yMargin: CGFloat) {
        var xMargin = BaseTractElement.xMargin
        if BaseTractElement.isCardElement(self) {
            xMargin = Card.xPaddingConstant
        }
        
        return ("toolFrontSubTitle",
                self.width,
                0.0,
                NSTextAlignment.left,
                xMargin,
                BaseTractElement.yMargin)
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
