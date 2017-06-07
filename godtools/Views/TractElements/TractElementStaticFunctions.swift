//
//  CheckElementKind.swift
//  godtools
//
//  Created by Devserker on 5/1/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

extension BaseTractElement {
    
    static func isRootElement(_ element: BaseTractElement) -> Bool {
        return BaseTractElement.isElement(element, kindOf: TractRoot.self)
    }
    
    static func isParagraphElement(_ element: BaseTractElement) -> Bool {
        return BaseTractElement.isElement(element, kindOf: TractParagraph.self)
    }
    
    static func isHeadingElement(_ element: BaseTractElement) -> Bool {
        return BaseTractElement.isElement(element, kindOf: TractHeading.self)
    }
    
    static func isHeaderElement(_ element: BaseTractElement) -> Bool {
        return BaseTractElement.isElement(element, kindOf: TractHeader.self)
    }
    
    static func isNumberElement(_ element: BaseTractElement) -> Bool {
        return BaseTractElement.isElement(element, kindOf: TractNumber.self)
    }
    
    static func isCardElement(_ element: BaseTractElement) -> Bool {
        return BaseTractElement.isElement(element, kindOf: TractCard.self)
    }
    
    static func isCallToActionElement(_ element: BaseTractElement) -> Bool {
        return BaseTractElement.isElement(element, kindOf: TractCallToAction.self)
    }
    
    static func isTitleElement(_ element: BaseTractElement) -> Bool {
        return BaseTractElement.isElement(element, kindOf: TractTitle.self)
    }
    
    static func isFormElement(_ element: BaseTractElement) -> Bool {
        return BaseTractElement.isElement(element, kindOf: TractForm.self)
    }
    
    static func isModalElement(_ element: BaseTractElement) -> Bool {
        return BaseTractElement.isElement(element, kindOf: TractModal.self)
    }
    
    static func getFormForElement(_ element: BaseTractElement) -> TractForm? {
        var elementCopy: BaseTractElement? = element
        
        while elementCopy != nil {
            if elementCopy!.isKind(of: TractForm.self) {
                return elementCopy as? TractForm
            }
            elementCopy = elementCopy!.parent
        }
        
        return nil
    }
    
    static func isElement(_ element: BaseTractElement, kindOf tractClass: AnyClass) -> Bool {
        var elementCopy: BaseTractElement? = element
        
        while elementCopy != nil {
            if elementCopy!.isKind(of: tractClass) {
                return true
            }
            elementCopy = elementCopy!.parent
        }
        
        return false
    }
    
}
