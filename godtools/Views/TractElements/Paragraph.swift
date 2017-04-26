//
//  Paragraph.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class Paragraph: BaseTractElement {
    let paddingConstant = CGFloat(12.0)
    
    var children = [BaseTractElement]()
    
    var textScale = Float(1.0)
    
    override func render() -> UIView {
        self.frame = CGRect(x: parentFrame().origin.x + paddingConstant,
                            y: parentFrame().origin.y + paddingConstant,
                            width: parentFrame().size.width - paddingConstant * 2,
                            height: 0)
        
        let view = UIView(frame: self.frame)
        
        view.backgroundColor = .green
        
        var requiredHeight = CGFloat(0.0)
        
        for child in children {
            let childView = child.render()
            requiredHeight += childView.frame.size.height
            view.addSubview(childView)
        }
        
        self.frame = CGRect(x: self.frame.origin.x,
                            y: self.frame.origin.y,
                            width: self.frame.size.width,
                            height: requiredHeight + paddingConstant)
        
        view.frame = self.frame
        
        return view
    }
    
}
