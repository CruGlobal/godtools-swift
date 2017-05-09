//
//  CallToAction.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class CallToAction: BaseTractElement {
    
    static let yMarginConstant = CGFloat(16.0)
    static let paddingConstant = CGFloat(16.0)
    
    var xPosition: CGFloat {
        return Card.xMarginConstant
    }
    var yPosition: CGFloat {
        return self.yStartPosition + CallToAction.yMarginConstant
    }
    override var width: CGFloat {
        return (self.parent?.width)! - self.xPosition - Card.xMarginConstant
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        self.frame = buildFrame()
        self.backgroundColor = .green
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height + CallToAction.yMarginConstant
    }
    
    override func textStyle() -> TextStyle {
        let textStyle = super.textStyle()
        textStyle.width = self.width
        textStyle.xMargin = CallToAction.paddingConstant
        textStyle.yMargin = CallToAction.paddingConstant
        textStyle.textColor = self.textColor
        return textStyle
    }
    
    override func textYPadding() -> CGFloat {
        return 15.0
    }
    
    // MARK: - Helpers
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: self.width,
                      height: self.height)
    }

}
