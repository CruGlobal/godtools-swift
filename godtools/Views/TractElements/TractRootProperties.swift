//
//  TractRootProperties.swift
//  godtools
//
//  Created by Devserker on 5/29/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractRootProperties: TractElementProperties {
    
    var primaryColor: UIColor?
    var primaryTextColor: UIColor?
    var textColor: UIColor?
    var backgroundProperties = TractBackgroundProperties()
    
    override func load(_ properties: [String: Any]) {
        super.load(properties)
        
        for property in properties.keys {
            switch property {
            case "primary-color":
                self.primaryColor = (properties[property] as! String).getRGBAColor()
            case "primary-text-color":
                self.primaryTextColor = (properties[property] as! String).getRGBAColor()
            case "text-color":
                self.textColor = (properties[property] as! String).getRGBAColor()
            default: break
            }
        }
        
        self.backgroundProperties.load(properties)
    }

}
