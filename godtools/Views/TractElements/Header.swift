//
//  Header.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class Header: BaseTractElement {
    
    let paddingConstant = CGFloat(30.0)
    
    override func setupView(properties: Dictionary<String, Any>) {
        let frame = CGRect(x: 0.0, y: self.yStartPosition  + paddingConstant, width: BaseTractElement.Standards.screenWidth, height: self.height)
        let view = UIView(frame: frame)
        view.backgroundColor = .black
        self.view = view
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yStartPosition + self.height + paddingConstant
    }

}
