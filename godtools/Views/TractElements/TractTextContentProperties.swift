//
//  TractTextContentProperties.swift
//  godtools
//
//  Created by Devserker on 5/8/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractTextContentProperties: TractElementProperties {
    
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
    
    override func load(_ properties: [String: Any]) {
        super.load(properties)
        
        for property in properties.keys {
            switch property {
            case "value":
                self.value = properties[property] as? String
            case "i18n-id":
                self.i18nId = properties[property] as? String
            case "text-color":
                self.color = (properties[property] as? String)!.getRGBAColor()
            case "text-scale":
                self.scale = properties[property] as? CGFloat
            case "text-align":
                self.align = (properties[property] as? NSTextAlignment)!
            default: break
            }
        }
    }

}
