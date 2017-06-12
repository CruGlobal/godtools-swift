//
//  TractElementFrame.swift
//  godtools
//
//  Created by Pablo Marti on 6/12/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractElementFrame: NSObject {
    
    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
    var xOrigin: CGFloat = 0.0
    var yMarginTop: CGFloat = 0.0
    var yMarginBottom: CGFloat = 0.0
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    
    func yEndPosition() -> CGFloat {
        return self.y + self.height + self.yMarginTop + self.yMarginBottom
    }
    
    func getFrame() -> CGRect {
        return CGRect(x: self.x,
                      y: self.y,
                      width: self.width,
                      height: self.height)
    }

}
