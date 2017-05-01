//
//  Number.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class Number: BaseTractElement {
    
    let paddingConstant = CGFloat(30.0)
    static let widthConstant = CGFloat(50.0)
    
    override func setupView(properties: Dictionary<String, Any>) {
        let frame = CGRect(x: 0.0, y: self.yStartPosition  + paddingConstant, width: Number.widthConstant, height: self.height)
        let view = UIView(frame: frame)
        view.backgroundColor = .green
        self.view = view
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yStartPosition + self.height + paddingConstant
    }

}
