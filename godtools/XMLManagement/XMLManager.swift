//
//  XMLManager.swift
//  godtools
//
//  Created by Pablo Marti on 6/8/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import SWXMLHash
import Crashlytics

class XMLManager: NSObject {
    
    var parser = XMLParseManager()
    
    func getContentElements(_ data: XMLIndexer) -> (elementName: String, namespace: String, kind: String, properties: Dictionary<String, Any>, children: [XMLIndexer]) {
        let elementName = data.element?.name
        let namespaceInfo = getNamespaceInfo(elementName!)
        let namespace = namespaceInfo.namespace
        let kind = namespaceInfo.kind
        
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
    
    func loadAttributesIntoObject(object: XMLNode, properties: [String: Any]) {
        for property in properties {
            assignValueFromAttribute(object: object, attribute: property.key, value: property.value as! String)
        }
    }
    
    func assignValueFromAttribute(object: XMLNode, attribute: String, value: String) {
        let propertyName = attribute.camelCased
        
        if object.customProperties() != nil && object.customProperties()!.contains(propertyName) {
            object.performCustomProperty(propertyName: propertyName, value: value)
            return
        }
        
        let objectMirror = Mirror(reflecting: object)
        let matchedProperty = objectMirror.children.filter( { $0.label == propertyName }).first
        
        if matchedProperty == nil {
            return
        }
        
        let propertyType = type(of: matchedProperty!.value)
        
        if propertyType == String.self || propertyType == Optional<String>.self {
            object.setValue(value, forKey: propertyName)
        } else if propertyType == CGFloat.self {
            guard let newValue = NumberFormatter().number(from: value) else { return }
            object.setValue(newValue, forKey: propertyName)
        } else if propertyType == Bool.self {
            let newValue = value == "true" ? true : false
            object.setValue(newValue, forKey: propertyName)
        } else if propertyType == UIColor.self || propertyType == Optional<UIColor>.self {
            let newValue = value.getRGBAColor()
            object.setValue(newValue, forKey: propertyName)
        }
    }
    
    private func getNamespaceInfo(_ elementName: String) -> (namespace: String, kind: String) {
        let elementNameArray = elementName.components(separatedBy: ":")
        var namespace = ""
        var kind = ""
        
        if (elementNameArray.count) > 1 {
            namespace = elementNameArray[0] as String
            kind = elementNameArray[1] as String
        } else {
            kind = elementNameArray[0] as String
        }
        
        return (namespace, kind)
    }

}
