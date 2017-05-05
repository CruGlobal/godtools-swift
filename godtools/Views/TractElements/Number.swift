//
//  Number.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class Number: BaseTractElement {
    
    static let widthConstant = CGFloat(70.0)
    static let marginConstant = CGFloat(8.0)
    
    var xPosition: CGFloat {
        return Number.marginConstant
    }
    var yPosition: CGFloat {
        return self.yStartPosition
    }
    override var width: CGFloat {
        return Number.widthConstant
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        self.frame = buildFrame()
    }
    
    override func textStyle() -> (style: String, width: CGFloat, height: CGFloat, alignment: NSTextAlignment, xMargin: CGFloat, yMargin: CGFloat) {
        return ("pageHeaderNumber",
                self.width,
                60.0,
                NSTextAlignment.center,
                BaseTractElement.Standards.xMargin,
                BaseTractElement.Standards.yMargin)
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
