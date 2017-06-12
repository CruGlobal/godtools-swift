//
//  TractTitle.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TractTitle: BaseTractElement {
    
    // MARK: Positions constants
    
    static let marginConstant: CGFloat = 8.0
    
    // MARK: - Positions and Sizes
    
    var xPosition: CGFloat {
        if (self.parent?.isKind(of: TractHeader.self))! && (self.parent as! TractHeader).properties.includesNumber {
            return TractNumber.marginConstant + TractNumber.widthConstant + TractTitle.marginConstant
        } else if (BaseTractElement.isModalElement(self)) {
            return (self.parent!.width - TractModal.contentWidth) / CGFloat(2)
        } else {
            return TractTitle.marginConstant
        }
    }
    var yPosition: CGFloat {
        return self.yStartPosition
    }
    
    override var width: CGFloat {
        return (self.parent?.width)! - self.xPosition - TractTitle.marginConstant
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height
    }
    
    // MARK: - Setup
    
    var properties = TractTitleProperties()
    
    override func textStyle() -> TractTextContentProperties {
        let textStyle = super.textStyle()
        textStyle.color = .gtWhite
        
        if BaseTractElement.isModalElement(self) {
            textStyle.font = .gtThin(size: 54.0)
            textStyle.width = TractModal.contentWidth
            textStyle.textAlign = .center
        } else {
            textStyle.font = .gtThin(size: 18.0)
            textStyle.width = self.width
        }
        
        return textStyle
    }
    
    func loadFrameProperties() {
        self.properties.frame.x = self.xPosition
        self.properties.frame.y = self.yPosition
        self.properties.frame.width = self.width
        self.properties.frame.height = self.height
    }
    
    override func buildFrame() -> CGRect {
        return self.properties.frame.getFrame()
    }

}
