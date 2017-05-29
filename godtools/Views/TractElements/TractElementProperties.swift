//
//  TractElementProperties.swift
//  godtools
//
//  Created by Devserker on 5/29/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractElementProperties: NSObject {
    
    var listeners: String?
    var dismissListeners: String?
    var hidden = false
    var listener: String?
    
    func load(_ properties: [String: Any]) {
        for property in properties.keys {
            switch property {
            case "listeners":
                self.listeners = properties[property] as! String?
            case "dismiss-listeners":
                self.dismissListeners = properties[property] as! String?
            case "hidden":
                self.hidden = true
            case "listener":
                self.listener = properties[property] as! String?
            default: break
            }
        }
    }
    
}
