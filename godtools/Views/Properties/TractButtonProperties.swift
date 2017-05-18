//
//  TractButtonProperties.swift
//  godtools
//
//  Created by Devserker on 5/12/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractButtonProperties {
    
    var i18nId: String?
    var type: String?
    var value: String?
    var width: CGFloat = 300.0
    var height: CGFloat = 44.0
    var xMargin = BaseTractElement.xMargin
    var yMargin = BaseTractElement.yMargin
    var cornerRadius: CGFloat = 5.0
    var backgroundColor = UIColor.gtBlue
    var color = UIColor.gtBlack
    var font = UIFont.gtRegular(size: 15.0)
}
