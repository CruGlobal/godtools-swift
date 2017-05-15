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
    
    var xPosition: CGFloat {
        return 0.0
    }
    var yPosition: CGFloat {
        return self.yStartPosition + 1.0
    }
    override var height: CGFloat {
        get {
            return super.height + 10.0
        }
        set {
            super.height = newValue
        }
    }
    
    override var horizontalContainer: Bool {
        return true
    }
    
    override func setupView(properties: [String: Any]) {
        self.frame = buildFrame()
        self.backgroundColor = self.primaryColor?.withAlphaComponent(0.9)
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height
    }
    
    // MARK: - Helpers
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: self.width,
                      height: self.height)
    }

}
