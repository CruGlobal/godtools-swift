//
//  TractTextFieldProperties.swift
//  godtools
//
//  Created by Devserker on 5/16/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractTextFieldProperties: TractElementProperties {
    
    var type: String?
    var name: String?
    var value: String?
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
    
    override func loadProperties(properties: [String: Any]) {
        super.loadProperties(properties: properties)
        
        for property in properties.keys {
            switch property {
            case "value":
                self.value = properties[property] as! String?
            case "name":
                self.name = properties[property] as! String?
            case "type":
                self.type = properties[property] as! String?
            default: break
            }
        }
    }
    
}
