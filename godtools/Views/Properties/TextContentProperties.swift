//
//  TextContentProperties.swift
//  godtools
//
//  Created by Devserker on 5/8/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TextContentProperties {
    
    var i18nId: String?
    var color: UIColor = .gtBlack
    var scale: CGFloat?
    var align: NSTextAlignment = .left
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    var xMargin: CGFloat = BaseTractElement.xMargin
    var yMargin: CGFloat = BaseTractElement.yMargin
    var value: String?
    var font = UIFont.gtRegular(size: 15.0)

}
