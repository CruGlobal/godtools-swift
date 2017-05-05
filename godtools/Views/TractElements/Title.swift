//
//  Title.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class Title: BaseTractElement {
    
    static let marginConstant = CGFloat(8.0)
    
    var xPosition: CGFloat {
        return Number.marginConstant + Number.widthConstant + Title.marginConstant
    }
    var yPosition: CGFloat {
        return self.yStartPosition
    }
    override var width: CGFloat {
        return (self.parent?.width)! - self.xPosition - Title.marginConstant
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        self.frame = buildFrame()
    }
    
    override func textStyle() -> (style: String, width: CGFloat, height: CGFloat, alignment: NSTextAlignment, xMargin: CGFloat, yMargin: CGFloat) {
        return ("pageHeaderTitle",
                self.width,
                0.0,
                NSTextAlignment.left,
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
