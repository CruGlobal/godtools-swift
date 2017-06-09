//
//  ManifestProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/9/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class ManifestProperties: NSObject {
    
    var listeners: String?
    var dismissListeners: String?
    var hidden = false
    
    let xmlManager = XMLManager()
    
    func load(_ properties: [String: Any]) {
        xmlManager.loadAttributesIntoObject(object: self, properties: properties)
    }

}
