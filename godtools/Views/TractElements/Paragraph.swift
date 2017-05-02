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
    
    let paddingConstant = CGFloat(30.0)
    
    override func setupView(properties: Dictionary<String, Any>) {
        let frame = CGRect(x: 0.0, y: self.yStartPosition + paddingConstant, width: BaseTractElement.Standards.screenWidth, height: self.height)
        let view = UIView(frame: frame)
        view.backgroundColor = .blue
        self.view = view
    }
    
    override func configureLabelStyle() -> (style: String, width: CGFloat, height: CGFloat) {
        return ("toolFrontSubTitle", BaseTractElement.Standards.textContentWidth, CGFloat(0.0))
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yStartPosition + self.height + paddingConstant
    }
    
}
