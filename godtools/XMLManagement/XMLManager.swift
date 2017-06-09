//
//  XMLManager.swift
//  godtools
//
//  Created by Pablo Marti on 6/8/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import SWXMLHash

class XMLManager: NSObject {
    
    func getContentElements(_ data: XMLIndexer) -> (elementName: String, namespace: String, kind: String, properties: Dictionary<String, Any>, children: [XMLIndexer]) {
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
    
    func loadAttributesIntoObject(object: NSObject, properties: [String: Any]) {
        for property in properties {
            assignValueFromAttribute(object: object, attribute: property.key, value: property.value as! String)
        }
    }
    
    func assignValueFromAttribute(object: NSObject, attribute: String, value: String) {
        let propertyName = attribute.camelCased
        let property = self.value(forKey: propertyName)
        
        switch property {
        case is String:
            self.setValue(value, forKey: propertyName)
        case is CGFloat:
            guard let newValue = NumberFormatter().number(from: value) else { return }
            self.setValue(newValue, forKey: propertyName)
        case is Bool:
            let newValue = value == "true" ? true : false
            self.setValue(newValue, forKey: propertyName)
        case is UIColor:
            let newValue = value.getRGBAColor()
            self.setValue(newValue, forKey: propertyName)
        default:
            let selectorName = "setup" + propertyName.capitalized
            object.perform(Selector(selectorName), with: value)
        }
    }

}
