//
//  TractParagraph.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TractParagraph: BaseTractElement {
    
    // MARK: Positions constants
    
    static let marginConstant: CGFloat = 8.0
    
    // MARK: - Positions and Sizes
    
    var xPosition: CGFloat {
        if BaseTractElement.isModalElement(self) {
            return (self.parent!.width - TractModal.contentWidth) / CGFloat(2)
        } else {
            return CGFloat(0)
        }
    }
    
    override var width: CGFloat {
        if BaseTractElement.isModalElement(self) {
            return TractModal.contentWidth
        } else {
            return self.parent!.width - (self.xPosition * CGFloat(2))
        }
    }
    
    // MARK: - Setup
    
    var properties = TractParagraphProperties()
    
    override func textStyle() -> TractTextContentProperties {
        if BaseTractElement.isModalElement(self) {
            return buildModalParagraph()
        } else {
            return buildStandardParagraph()
        }
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = self.xPosition
        self.elementFrame.y = self.elementFrame.yOrigin + TractParagraph.marginConstant
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
    }
    
    // MARK: - Helpers
    
    func buildModalParagraph() -> TractTextContentProperties {        
        let textStyle = super.textStyle()
        textStyle.font = .gtRegular(size: 18.0)
        textStyle.width = self.width
        textStyle.xMargin = BaseTractElement.xMargin
        textStyle.color = .gtWhite
        textStyle.textAlign = .center
        
        return textStyle
    }
    
    func buildStandardParagraph() -> TractTextContentProperties {
        var xMargin = BaseTractElement.xMargin
        
        if BaseTractElement.isCardElement(self) {
            xMargin = TractCard.xPaddingConstant
        }
        
        let textStyle = super.textStyle()
        textStyle.font = .gtRegular(size: 18.0)
        textStyle.width = self.width
        textStyle.xMargin = xMargin
        textStyle.color = self.textColor
        
        return textStyle
    }
    
}
