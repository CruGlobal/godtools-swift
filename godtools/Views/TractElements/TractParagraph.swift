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
