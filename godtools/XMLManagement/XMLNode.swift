//
//  XMLNode.swift
//  godtools
//
//  Created by Pablo Marti on 6/9/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class XMLNode: NSObject {
    
    var listeners: String?
    var dismissListeners: String?
    var hidden = false
    
    let xmlManager = XMLManager()
    
    final func load(_ properties: [String: Any]) {
        xmlManager.loadAttributesIntoObject(object: self, properties: properties)
    }
    
    func loadCustomProperties(_ properties: [String: Any]) { }
    
    func performCustomProperty(propertyName: String, value: String) {}
    
    func properties() -> [String] {
        return Mirror(reflecting: self).children.flatMap{$0.label}
    }
    
    func customProperties() -> [String]? {
        return nil
    }

}
