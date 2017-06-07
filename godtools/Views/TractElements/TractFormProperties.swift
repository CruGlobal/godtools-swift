//
//  TractFormProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/7/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractFormProperties: TractElementProperties {
    
    var action: String?
    
    override func load(_ properties: [String: Any]) {
        super.load(properties)
        
        for property in properties.keys {
            switch property {
            case "action":
                self.action = properties[property] as! String
            default: break
            }
        }
    }

}
