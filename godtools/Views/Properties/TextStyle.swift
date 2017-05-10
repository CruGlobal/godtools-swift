//
//  TextStyle.swift
//  godtools
//
//  Created by Devserker on 5/8/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TextStyle: NSObject {
    
    var style: String = "blackText"
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    var xMargin: CGFloat = BaseTractElement.Standards.xMargin
    var yMargin: CGFloat = BaseTractElement.Standards.yMargin
    var alignment: NSTextAlignment = .left
    var textColor: UIColor = .gtBlack

}
