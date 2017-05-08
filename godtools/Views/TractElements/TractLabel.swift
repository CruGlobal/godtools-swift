//
//  TractLabel.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash

class TractLabel: BaseTractElement {
    
    static let xMarginConstant = CGFloat(0.0)
    static let yMarginConstant = CGFloat(0.0)
    
    var tapView = UIView()
    var xPosition: CGFloat {
        return TractLabel.xMarginConstant
    }
    var yPosition: CGFloat {
        return self.yStartPosition + TractLabel.yMarginConstant
    }
    override var width: CGFloat {
        return (self.parent?.width)! - self.xPosition - TractLabel.xMarginConstant
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        self.frame = buildFrame()
    }
    
    func buildHorizontalLine() {
        let xPosition = Card.xPaddingConstant
        let yPosition = self.frame.size.height - 1
        let width = self.frame.size.width - (Card.xPaddingConstant * CGFloat(2))
        let height = CGFloat(1.0)
        
        let horizontalLine = UIView()
        horizontalLine.frame = CGRect(x: xPosition,
                                      y: yPosition,
                                      width: width,
                                      height: height)
        horizontalLine.backgroundColor = UIColor.gtGreyLight
        self.addSubview(horizontalLine)
        
    }
    
    override func render() -> UIView {
        for element in self.elements! {
            self.addSubview(element.render())
        }
        setupPressGestures()
        buildHorizontalLine()
        return self
    }
    
    override func textStyle() -> TextStyle {
        let textStyle = super.textStyle()
        textStyle.style = "tabTitle"
        textStyle.width = self.width
        textStyle.xMargin = Card.xPaddingConstant
        textStyle.textColor = self.primaryColor!
        return textStyle
    }
    
    override func textYPadding() -> CGFloat {
        return 15.0
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yStartPosition + self.height
    }
    
    // MARK: - Helpers
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: self.width,
                      height: self.height)
    }

}
