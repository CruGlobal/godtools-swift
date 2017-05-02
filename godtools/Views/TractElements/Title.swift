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
    
    static let paddingConstant = CGFloat(8.0)
    
    var xPosition: CGFloat {
        return Number.widthConstant + Number.paddingConstant + Title.paddingConstant
    }
    override var width: CGFloat {
        return (self.parent?.width)! - self.xPosition - Title.paddingConstant
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        let frame = buildFrame()
        let view = UIView(frame: frame)
        view.backgroundColor = .red
        self.view = view
    }
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yStartPosition + Title.paddingConstant,
                      width: self.width,
                      height: self.height)
    }
    
    override func textStyle() -> (style: String, width: CGFloat, height: CGFloat) {
        return ("pageHeaderTitle", self.width, CGFloat(0.0))
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yStartPosition + self.height + Title.paddingConstant
    }

}
