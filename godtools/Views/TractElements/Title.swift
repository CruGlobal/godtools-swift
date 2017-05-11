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
    
    static let marginConstant: CGFloat = 8.0
    
    var xPosition: CGFloat {
        return Number.marginConstant + Number.widthConstant + Title.marginConstant
    }
    var yPosition: CGFloat {
        return self.yStartPosition
    }
    override var width: CGFloat {
        return (self.parent?.width)! - self.xPosition - Title.marginConstant
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        self.frame = buildFrame()
    }
    
    override func textStyle() -> TextContentProperties {
        let textStyle = super.textStyle()
        textStyle.style = "pageHeaderTitle"
        textStyle.width = self.width
        textStyle.color = .gtWhite
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
