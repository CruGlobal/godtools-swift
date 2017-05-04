//
//  Paragraph.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class Paragraph: BaseTractElement {
    
    static let marginConstant = CGFloat(8.0)
    
    var xPosition: CGFloat {
        return Paragraph.marginConstant
    }
    var yPosition: CGFloat {
        return self.yStartPosition + Paragraph.marginConstant
    }
    override var width: CGFloat {
        return (self.parent?.width)! - self.xPosition - Paragraph.marginConstant
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        self.frame = buildFrame()
        self.backgroundColor = .blue
    }
    
    override func textStyle() -> (style: String, width: CGFloat, height: CGFloat) {
        return ("toolFrontSubTitle", self.width, CGFloat(0.0))
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height
    }
    
    // MARK: - Helpers
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: self.width,
                      height: self.height)
    }
    
}
