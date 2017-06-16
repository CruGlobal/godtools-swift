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
        return CGRect(x: finalX(),
                      y: finalY(),
                      width: finalWidth(),
                      height: finalHeight())
    }
    
    func finalX() -> CGFloat {
        return self.x + self.xMargin
    }
    
    func finalY() -> CGFloat {
        return self.y + self.yMarginTop
    }
    
    func finalWidth() -> CGFloat {
        return self.width - (self.xMargin * 2)
    }
    
    func finalHeight() -> CGFloat {
        return self.height + self.yMarginBottom
    }

}
