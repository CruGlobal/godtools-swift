//
//  TractInputProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/12/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractInputProperties: TractProperties {
    
    // MARK: - XML Properties
    
    var name: String?
    var type: String?
    var value: String?
    
    override func defineProperties() {
        self.properties = ["name", "type", "value"]
    }
    
    // MARK: - View Properties
    
    var width: CGFloat = 300.0
    var height: CGFloat = 44.0
    var xMargin = BaseTractElement.xMargin
    var yMargin = BaseTractElement.yMargin
    var cornerRadius: CGFloat = 5.0
    var borderWidth: CGFloat = 0.6
    var backgroundColor = UIColor.gtWhite
    var color = UIColor.gtBlack
    var font = UIFont.gtRegular(size: 16.0)
    var placeholder: String?

}
