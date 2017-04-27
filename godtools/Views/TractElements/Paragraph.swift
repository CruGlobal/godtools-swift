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
    var children = [BaseTractElement]()
    
    let paddingConstant = CGFloat(30.0)
    
    var textScale = Float(1.0)
 
    override func render(yPos: CGFloat) -> UIView {
        var subviews = [UIView]()
        var currentY = paddingConstant
        
        for child in children {
            let view = child.render(yPos: currentY)
            subviews.append(view)
            currentY += view.frame.size.height + paddingConstant
        }
        
        let view = UIView(frame: CGRect(x: 0,
                                        y: yPos,
                                        width: BaseTractElement.Standards.screenWidth,
                                        height: currentY))
        
        view.backgroundColor = .green
        
        for subview in subviews {
            view.addSubview(subview)
        }
        
        return view
    }
}
