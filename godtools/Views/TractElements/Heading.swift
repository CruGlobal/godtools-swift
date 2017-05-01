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
    
    override func setupView(properties: Dictionary<String, Any>) {
        let frame = CGRect(x: 0.0, y: self.yStartPosition  + paddingConstant, width: BaseTractElement.Standards.screenWidth, height: self.height)
        let view = UIView(frame: frame)
        view.backgroundColor = .green
        self.view = view
    }
    
    override func configureLabelStyle() -> (style: String, dynamic: Bool, height: CGFloat) {
        return ("toolFrontTitle", 0.0)
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yStartPosition + self.height + paddingConstant
    }

}
