//
//  Hero.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class Hero: BaseTractElement {
    
    override func setupView(properties: Dictionary<String, Any>) {
        let frame = CGRect(x: 0.0, y: self.yStartPosition + BaseTractElement.Standards.yPadding, width: BaseTractElement.Standards.screenWidth, height: self.height)
        let view = UIView(frame: frame)
        self.view = view
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yStartPosition + self.height + BaseTractElement.Standards.yPadding
    }
        
}
