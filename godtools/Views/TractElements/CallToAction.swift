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
    let buttonSizeConstant = CGFloat(22.0)
    let buttonSizeXMargin = CGFloat(8.0)
    var buttonXPosition: CGFloat {
        return self.width - self.buttonSizeConstant - self.buttonSizeXMargin
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        self.frame = buildFrame()
        addArrowButton()
    }
    
    func addArrowButton() {
        let xPosition = self.buttonXPosition
        let yPosition = CallToAction.paddingConstant * 2
        let origin = CGPoint(x: xPosition, y: yPosition)
        let size = CGSize(width: self.buttonSizeConstant, height: self.buttonSizeConstant)
        let buttonFrame = CGRect(origin: origin, size: size)
        let button = UIButton(frame: buttonFrame)
        let image = UIImage(named: "right_arrow_black")
        button.setBackgroundImage(image, for: UIControlState.normal)
        self.addSubview(button)
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height + CallToAction.yMarginConstant
    }
    
    override func textStyle() -> TextStyle {
        let textStyle = super.textStyle()
        textStyle.width = self.width - self.buttonSizeConstant - (self.buttonSizeXMargin * CGFloat(2))
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
