//
//  Title.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class Title: BaseTractElement {
    
    let xPaddingConstant = CGFloat(10.0)
    let yPaddingConstant = CGFloat(30.0)
    
    override func setupView(properties: Dictionary<String, Any>) {
        let frame = CGRect(x: titleXPosition(),
                           y: self.yStartPosition  + self.yPaddingConstant,
                           width: titleWidth(),
                           height: self.height)
        let view = UIView(frame: frame)
        view.backgroundColor = .red
        self.view = view
    }
    
    override func configureLabelStyle() -> (style: String, dynamic: Bool, height: CGFloat) {
        return ("pageHeaderTitle", 48.0)
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yStartPosition + self.height + self.yPaddingConstant
    }
    
    fileprivate func titleXPosition() -> CGFloat {
        return Number.widthConstant + self.xPaddingConstant
    }
    
    fileprivate func titleWidth() -> CGFloat {
        return BaseTractElement.Standards.screenWidth - titleXPosition()
    }

}
