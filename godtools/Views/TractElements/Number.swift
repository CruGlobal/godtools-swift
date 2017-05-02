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
    
    static let widthConstant = CGFloat(50.0)
    let paddingConstant = CGFloat(30.0)
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
        return CGRect(x: 0.0,
                      y: self.yStartPosition + paddingConstant,
                      width: self.width,
                      height: self.height)
    }
    
    override func textStyle() -> (style: String, width: CGFloat, height: CGFloat) {
        return ("pageHeaderNumber", self.width, CGFloat(60.0))
    }
    
    override func yEndPosition() -> CGFloat {
        // return self.yStartPosition + self.height + paddingConstant
        return 0.0
    }

}
