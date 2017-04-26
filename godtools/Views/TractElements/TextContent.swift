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
    let paddingConstant = CGFloat(5.0)
    
    var textScale = Float(1.0)
    var textColor = UIColor.black

    var text = ""

    func createFrameFromParent() -> CGRect {
        return CGRect(x: paddingConstant,
                      y: paddingConstant,
                      width: parentFrame().size.width - paddingConstant * 2,
                      height: 0.0)
    }
    
    override func render() -> UIView {
        let frame = createFrameFromParent()
        let label = UILabel(frame: frame)
        
        label.font = UIFont(name: "Helvetica", size: 16.0)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = self.text
        label.sizeToFit()
        
        label.backgroundColor = .blue
        
        rootView?.currentY += label.frame.size.height
        
        return label
    }
}
