//
//  TractLabel.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TractLabel: BaseTractElement {
    
    static let paddingConstant = CGFloat(8.0)
    
    var xPosition: CGFloat {
        return TractLabel.paddingConstant
    }
    override var width: CGFloat {
        return (self.parent?.width)! - self.xPosition - TractLabel.paddingConstant
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        let frame = buildFrame()
        let view = UIView(frame: frame)
        view.backgroundColor = .gtGreen
        self.view = view
    }
    
    override func textStyle() -> (style: String, width: CGFloat, height: CGFloat) {
        return ("tabTitle", self.width, CGFloat(0.0))
    }
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yStartPosition + TractLabel.paddingConstant,
                      width: self.width,
                      height: self.height)
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yStartPosition + self.height
    }

}
