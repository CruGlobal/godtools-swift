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
        if (self.parent?.isKind(of: Header.self))! && (self.parent as! Header).includesNumber {
            return Number.marginConstant + Number.widthConstant + Title.marginConstant
        } else {
            return Title.marginConstant
        }
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
        textStyle.font = .gtThin(size: 18.0)
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
