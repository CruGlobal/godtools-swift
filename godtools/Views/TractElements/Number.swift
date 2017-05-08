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
        return self.yStartPosition
    }
    override var width: CGFloat {
        return Number.widthConstant
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        self.frame = buildFrame()
    }
    
    override func textStyle() -> TextStyle {
        let textStyle = super.textStyle()
        textStyle.style = "pageHeaderNumber"
        textStyle.width = self.width
        textStyle.height = 60.0
        textStyle.alignment = .center
        textStyle.textColor = .gtWhite
        return textStyle
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
