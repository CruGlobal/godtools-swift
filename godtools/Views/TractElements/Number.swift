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
        return self.yStartPosition + Number.marginConstant
    }
    override var width: CGFloat {
        return Number.widthConstant
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        let frame = buildFrame()
        let view = UIView(frame: frame)
        view.backgroundColor = .green
        self.view = view
    }
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: self.width,
                      height: self.height)
    }
    
    override func textStyle() -> (style: String, width: CGFloat, height: CGFloat) {
        return ("pageHeaderNumber", self.width, CGFloat(60.0))
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height
    }

}
