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
    var properties = [String]()
    
    final func load(_ properties: [String: Any]) {
        xmlManager.loadAttributesIntoObject(object: self, properties: properties)
    }
    
    func defineProperties() { }
    
    func getProperties() -> [String] {
        return self.properties
    }
    
    func customProperties() -> [String]? {
        return nil
    }
    
    func performCustomProperty(propertyName: String, value: String) { }

}
