//
//  Card.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class Card: BaseTractElement {
    
    static let paddingConstant = CGFloat(8.0)
    
    var xPosition: CGFloat {
        return Card.paddingConstant
    }
    var yPosition: CGFloat {
        return self.yStartPosition + Card.paddingConstant
    }
    override var width: CGFloat {
        return (self.parent?.width)! - self.xPosition - Card.paddingConstant
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
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height
    }

}
