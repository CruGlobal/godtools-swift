//
//  BaseTractElement.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class BaseTractElement: NSObject {
    var frame: CGRect
    weak var rootView: BaseTractView?
    weak var parent: BaseTractElement?
    
    init(xml: Any?, rootView: BaseTractView?, parent: BaseTractElement?) {
        self.rootView = rootView
        self.parent = parent
        
        if rootView != nil {
            self.frame = rootView!.frame
        } else {
            self.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        
        super.init()
    }
    
    func parentFrame() -> CGRect {
        if parent != nil {
            return parent!.frame
        } else {
            return rootView!.frame
        }
    }
    
    func render() -> UIView {
        preconditionFailure("This function must be overridden")
    }
}
