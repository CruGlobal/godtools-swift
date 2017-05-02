//
//  Cards.swift
//  godtools
//
//  Created by Devserker on 5/2/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash

class Cards: BaseTractElement {
    
    override var height: CGFloat {
        get {
            return self.getMaxHeight()
        }
        set {
            // Unused
        }
    }
    
    init(children: [XMLIndexer], startOnY yPosition: CGFloat, parent: BaseTractElement) {
        super.init()
        self.parent = parent
        self.yStartPosition = yPosition
        buildChildrenForData(children)
        setupView(properties: Dictionary<String, Any>())
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        let frame = buildFrame()
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.darkGray
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
