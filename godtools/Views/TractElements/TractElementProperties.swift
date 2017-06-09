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
    
    let xmlManager = XMLManager()
    
    func load(_ properties: [String: Any]) {
        xmlManager.loadAttributesIntoObject(object: self, properties: properties)
    }
    
    func properties() -> [String] {
        return Mirror(reflecting: self).children.flatMap{$0.label?.dashCased}
    }
    
}
