//
//  TextContent.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TextContent: BaseTractElement {
    var textScale = CGFloat(1.0)
    var textColor = UIColor.black
    
    var text = ""

    override func render(yPos: CGFloat) -> UIView {
        let label = UILabel(frame: createFrame(yPos: yPos, height: 0))
        
        label.font = UIFont(name: "Helvetica", size: CGFloat(16.0) * textScale)
        label.text = text
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        
        label.backgroundColor = .yellow
        
        if BaseTractElement.isParagraphElement(self) {
            label.frame = createFrame(yPos: yPos, height: label.frame.size.height + CGFloat(20.0))
        }
        
        return label
    }
    
    fileprivate func createFrame(yPos: CGFloat, height: CGFloat) -> CGRect {
        return CGRect(x: BaseTractElement.Standards.xPadding,
                      y: yPos,
                      width: BaseTractElement.Standards.textContentWidth,
                      height: height)
    }
}
