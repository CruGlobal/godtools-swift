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
    
    let xPaddingConstant = CGFloat(10.0)
    let yPaddingConstant = CGFloat(30.0)
    var xPosition: CGFloat {
        return Number.widthConstant + self.xPaddingConstant
    }
    override var width: CGFloat {
        return (self.parent?.width)! - Number.widthConstant - (self.xPaddingConstant * CGFloat(2))
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        let frame = buildFrame()
        let view = UIView(frame: frame)
        view.backgroundColor = .red
        self.view = view
    }
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yStartPosition  + self.yPaddingConstant,
                      width: self.width,
                      height: self.height)
    }
    
    override func textStyle() -> (style: String, width: CGFloat, height: CGFloat) {
        return ("pageHeaderTitle", self.width, CGFloat(0.0))
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yStartPosition + self.height + self.yPaddingConstant
    }

}
