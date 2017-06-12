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
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    
    func getFrame() -> CGRect {
        return CGRect(x: self.x,
                      y: self.y,
                      width: self.width,
                      height: self.height)
    }

}
