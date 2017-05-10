//
//  Heading.swift
//  godtools
//
//  Created by Devserker on 4/27/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class Heading: BaseTractElement {
    
    let marginConstant: CGFloat = 30.0
    
    var xPosition: CGFloat = 0.0
    var yPosition: CGFloat {
        return self.yStartPosition + self.marginConstant
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        self.frame = buildFrame()
    }
    
    override func textStyle() -> (style: String, width: CGFloat, height: CGFloat, alignment: NSTextAlignment, xMargin: CGFloat, yMargin: CGFloat) {
        return ("toolFrontTitle",
                BaseTractElement.textContentWidth,
                0.0,
                NSTextAlignment.left,
                BaseTractElement.xMargin,
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
