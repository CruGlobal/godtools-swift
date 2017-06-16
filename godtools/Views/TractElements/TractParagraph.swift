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
    
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractParagraphProperties.self
    }
    
    override func loadFrameProperties() {
        var x: CGFloat {
            if BaseTractElement.isModalElement(self) {
                return (self.parent!.width - TractModal.contentWidth) / CGFloat(2)
            } else {
                return CGFloat(0)
            }
        }
        
        var width: CGFloat {
            if BaseTractElement.isModalElement(self) {
                return TractModal.contentWidth
            } else {
                return self.parent!.elementFrame.width - (x * CGFloat(2))
            }
        }
        
        self.elementFrame.x = x
        self.elementFrame.width = width
        self.elementFrame.yMarginTop = TractParagraph.marginConstant
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
