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
        return BaseTractElement.isElement(element, kindOf: Paragraph.self)
    }
    
    static func isHeadingElement(_ element: BaseTractElement) -> Bool {
        return BaseTractElement.isElement(element, kindOf: Heading.self)
    }
    
    static func isHeaderElement(_ element: BaseTractElement) -> Bool {
        return BaseTractElement.isElement(element, kindOf: Header.self)
    }
    
    static func isNumberElement(_ element: BaseTractElement) -> Bool {
        return BaseTractElement.isElement(element, kindOf: Number.self)
    }
    
    static func isCardElement(_ element: BaseTractElement) -> Bool {
        return BaseTractElement.isElement(element, kindOf: Card.self)
    }
    
    static func isTitleElement(_ element: BaseTractElement) -> Bool {
        return BaseTractElement.isElement(element, kindOf: Title.self)
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
