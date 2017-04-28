//
//  Heading.swift
//  godtools
//
//  Created by Devserker on 4/27/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class Heading: BaseTractElement {
    
    let paddingConstant = CGFloat(30.0)
    var textScale = Float(1.0)
    
    override func setupView(properties: Dictionary<String, Any>) {
        let frame = CGRect(x: 0.0, y: self.yStartPosition, width: BaseTractElement.Standards.screenWidth, height: self.height)
        let view = UIView(frame: frame)
        view.backgroundColor = .green
        self.view = view
    }
    
//    func render(yPos: CGFloat) -> UIView {
//        var subviews = [UIView]()
//        var currentY = paddingConstant
//        
//        for child in children {
//            let view = child.render(yPos: currentY)
//            subviews.append(view)
//            currentY += view.frame.size.height + paddingConstant
//        }
//        
//        let view = UIView(frame: CGRect(x: 0,
//                                        y: yPos,
//                                        width: BaseTractElement.Standards.screenWidth,
//                                        height: currentY))
//        
//        view.backgroundColor = .green
//        
//        for subview in subviews {
//            view.addSubview(subview)
//        }
//        
//        return view
//    }

}
