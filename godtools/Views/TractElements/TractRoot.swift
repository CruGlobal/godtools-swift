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
        let frame = CGRect(x: 0.0, y: self.yStartPosition, width: BaseTractElement.Standards.screenWidth, height: self.height)
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.yellow
        self.view = view
    }
    
}
