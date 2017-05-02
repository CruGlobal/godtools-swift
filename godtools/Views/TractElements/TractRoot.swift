//
//  TractRoot.swift
//  godtools
//
//  Created by Devserker on 4/27/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TractRoot: BaseTractElement {
    
    override func setupView(properties: Dictionary<String, Any>) {
        let frame = buildFrame()
        let view = UIView(frame: frame)
        view.backgroundColor = .yellow
        self.view = view
    }
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: 0.0,
                      y: self.yStartPosition,
                      width: self.width,
                      height: self.height)
    }
    
}
