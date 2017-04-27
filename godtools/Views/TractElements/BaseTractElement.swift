//
//  BaseTractElement.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class BaseTractElement: NSObject {
    struct Standards {
        static let xPadding = CGFloat(20.0)
        static let yPadding = CGFloat(5.0)
        
        static let screenWidth = UIScreen.main.bounds.size.width
        static let textContentWidth = UIScreen.main.bounds.size.width - xPadding * CGFloat(2)
    }
    
    weak var parent: BaseTractElement?

    static func isParagraphElement(_ element: BaseTractElement) -> Bool {
        var elementCopy: BaseTractElement? = element
        
        while elementCopy != nil {
            if elementCopy!.isKind(of: Paragraph.self) {
                return true
            }
            elementCopy = elementCopy!.parent
        }
        
        return false
    }
    
    func render(yPos: CGFloat) -> UIView {
        preconditionFailure("This function must be overridden")
    }
}
