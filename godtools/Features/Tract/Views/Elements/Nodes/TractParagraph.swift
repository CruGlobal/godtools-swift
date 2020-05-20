//
//  TractParagraph.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractParagraph: BaseTractElement {
    
    // MARK: Positions constants
    
    static let xMarginConstant: CGFloat = 0.0
    static let yMarginConstant: CGFloat = 8.0
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractParagraphProperties.self
    }
    
    override func loadFrameProperties() {
        if BaseTractElement.isModalElement(self) {
            buildModalFrame()
        } else {
            buildStandardFrame()
        }        
    }
    
    override func textStyle() -> TractTextContentProperties {
        if BaseTractElement.isModalElement(self) {
            return buildModalParagraph()
        } else {
            return buildStandardParagraph()
        }
    }
    
    // MARK: - Helpers
    
    func paragraphProperties() -> TractParagraphProperties {
        return self.properties as! TractParagraphProperties
    }
}

// MARK: - UI

extension TractParagraph {
    
    func buildModalParagraph() -> TractTextContentProperties {
        let properties = super.textStyle()
        properties.width = self.elementFrame.finalWidth()
        properties.xMargin = BaseTractElement.xMargin
        properties.textColor = .gtWhite
        properties.textAlign = .center
        return properties
    }
    
    func buildStandardParagraph() -> TractTextContentProperties {
        var xMargin: CGFloat{
            if BaseTractElement.isCardElement(self) {
                return 0.0
            } else {
                return BaseTractElement.xMargin
            }
        }
        
        let properties = super.textStyle()
        properties.width = self.elementFrame.finalWidth()
        properties.xMargin = xMargin
        return properties
    }
    
    func buildStandardFrame() {
        var xMargin: CGFloat{
            if BaseTractElement.isCardElement(self) {
                return TractCard.xPaddingConstant
            } else {
                return TractParagraph.xMarginConstant
            }
        }
        
        self.elementFrame.x = 0
        self.elementFrame.width = parentWidth()
        self.elementFrame.yMarginTop = TractParagraph.yMarginConstant
        self.elementFrame.yMarginBottom = TractParagraph.yMarginConstant
        self.elementFrame.xMargin = xMargin
    }
    
    func buildModalFrame() {
        let width = TractModal.contentWidth
        self.elementFrame.x = (self.parent!.width - width) / CGFloat(2)
        self.elementFrame.width = width
        self.elementFrame.yMarginTop = TractParagraph.yMarginConstant
        self.elementFrame.yMarginBottom = TractParagraph.yMarginConstant
    }
}
