//
//  XMLFunctions.swift
//  godtools
//
//  Created by Pablo Marti on 6/8/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import SWXMLHash

class XMLFunctions: NSObject {
    
    static func getContentElements(_ data: XMLIndexer) -> (elementName: String, namespace: String, kind: String, properties: Dictionary<String, Any>, children: [XMLIndexer]) {
        let elementName = data.element?.name
        let elementNameArray = elementName?.components(separatedBy: ":")
        var namespace = ""
        var kind = ""
        
        if (elementNameArray?.count)! > 1 {
            namespace = elementNameArray![0] as String
            kind = elementNameArray![1] as String
        } else {
            kind = elementNameArray![0] as String
        }
        
        var properties = [String: Any]()
        for item in (data.element?.allAttributes)! {
            let attribute = item.value as XMLAttribute
            properties[attribute.name] = attribute.text
        }
        
        if data.element?.text != nil && data.element?.text?.trimmingCharacters(in: .whitespaces) != "" {
            properties["value"] = data.element?.text
        }
        
        let children = data.children
        return (elementName!, namespace, kind, properties, children)
    }

}
