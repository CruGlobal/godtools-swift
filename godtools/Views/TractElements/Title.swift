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
        return self.yStartPosition + Title.marginConstant
    }
    override var width: CGFloat {
        return (self.parent?.width)! - self.xPosition - Title.marginConstant
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        self.frame = buildFrame()
        self.backgroundColor = .red
    }
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: self.width,
                      height: self.height)
    }
    
    override func textStyle() -> (style: String, width: CGFloat, height: CGFloat) {
        return ("pageHeaderTitle", self.width, CGFloat(0.0))
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yStartPosition + self.height
    }

}
