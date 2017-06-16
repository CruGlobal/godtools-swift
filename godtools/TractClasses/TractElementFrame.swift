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
    var xMargin: CGFloat = 0.0
    var yMarginTop: CGFloat = 0.0
    var yMarginBottom: CGFloat = 0.0
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    var maxHeight: CGFloat = 0.0
    
    func yEndPosition() -> CGFloat {
        return self.y + self.height + self.yMarginTop + self.yMarginBottom
    }
    
    func getFrame() -> CGRect {
        return CGRect(x: self.x + self.xMargin,
                      y: self.y + self.yMarginTop,
                      width: self.width - (self.xMargin * 2),
                      height: self.height - self.yMarginTop - self.yMarginBottom)
    }

}
