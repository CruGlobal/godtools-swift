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
    
    override var horizontalContainer: Bool {
        return true
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        let frame = buildFrame()
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.80)
        self.view = view
    }
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: 0.0,
                      y: self.yStartPosition,
                      width: self.width,
                      height: self.height)
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yStartPosition + self.height
    }

}
