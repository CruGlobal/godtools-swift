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
    
    func load(_ properties: [String: Any]) {
        xmlManager.loadAttributesIntoObject(object: self, properties: properties)
    }
    
    func properties() -> [String] {
        return Mirror(reflecting: self).children.flatMap{$0.label?.dashCased}
    }

}
