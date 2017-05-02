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
    static let paddingConstant = CGFloat(8.0)
    
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
        return CGRect(x: Number.paddingConstant,
                      y: self.yStartPosition + Number.paddingConstant,
                      width: self.width,
                      height: self.height)
    }
    
    override func textStyle() -> (style: String, width: CGFloat, height: CGFloat) {
        return ("pageHeaderNumber", self.width, CGFloat(60.0))
    }
    
    override func yEndPosition() -> CGFloat {
        return 0.0
    }

}
