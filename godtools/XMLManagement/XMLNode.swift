//
//  XMLNode.swift
//  godtools
//
//  Created by Pablo Marti on 6/9/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class XMLNode: NSObject {
    
    let xmlManager = XMLManager()
    
    final func load(_ properties: [String: Any]) {
        xmlManager.loadAttributesIntoObject(object: self, properties: properties)
    }
    
    func properties() -> [String]? {
        return nil
    }
    
    func customProperties() -> [String]? {
        return nil
    }
    
    func performCustomProperty(propertyName: String, value: String) {}

}
