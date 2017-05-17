//
//  TractCallToAction.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TractCallToAction: BaseTractElement {
    
    // MARK: - Positions and Sizes
    
    static let yMarginConstant: CGFloat = 16.0
    static let paddingConstant: CGFloat = 16.0
    
    var xPosition: CGFloat {
        return TractCard.xMarginConstant
    }
    
    override var width: CGFloat {
        return (self.parent?.width)! - self.xPosition - TractCard.xMarginConstant
    }
    
    static let minHeight: CGFloat = 80.0
    
    override var height: CGFloat {
        get {
            return super.height > TractCallToAction.minHeight ? super.height : TractCallToAction.minHeight
        }
        set {
            super.height = newValue
        }
    }
    
    var yPosition: CGFloat {
        var position = self.yStartPosition + TractCallToAction.yMarginConstant
        if position < (self.parent?.maxHeight)! - self.height {
            position = (self.parent?.maxHeight)! - self.height
        }
        return position
    }
    
    let buttonSizeConstant: CGFloat = 22.0
    
    let buttonSizeXMargin: CGFloat = 8.0
    
    var buttonXPosition: CGFloat {
        return self.width - self.buttonSizeConstant - self.buttonSizeXMargin
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height + TractCallToAction.yMarginConstant
    }
    
    override func textYPadding() -> CGFloat {
        return 15.0
    }
    
    // MARK: - Setup
    
    override func setupView(properties: Dictionary<String, Any>) {
        self.frame = buildFrame()
        addArrowButton()
    }
    
    func addArrowButton() {
        let xPosition = self.buttonXPosition
        let yPosition = (self.height - self.buttonSizeConstant) / 2
        let origin = CGPoint(x: xPosition, y: yPosition)
        let size = CGSize(width: self.buttonSizeConstant, height: self.buttonSizeConstant)
        let buttonFrame = CGRect(origin: origin, size: size)
        let button = UIButton(frame: buttonFrame)
        let image = UIImage(named: "right_arrow_blue")
        button.setBackgroundImage(image, for: UIControlState.normal)
        button.addTarget(self, action: #selector(moveToNextView), for: UIControlEvents.touchUpInside)
        self.addSubview(button)
    }
    
    func moveToNextView() {
        NotificationCenter.default.post(name: .moveToNextPageNotification, object: nil)
    }
    
    override func textStyle() -> TractTextContentProperties {
        let textStyle = super.textStyle()
        textStyle.width = self.width - self.buttonSizeConstant - (self.buttonSizeXMargin * CGFloat(2))
        textStyle.xMargin = TractCallToAction.paddingConstant
        textStyle.yMargin = TractCallToAction.paddingConstant
        textStyle.color = self.textColor
        return textStyle
    }
    
    // MARK: - Helpers
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: self.width,
                      height: self.height)
    }

}
