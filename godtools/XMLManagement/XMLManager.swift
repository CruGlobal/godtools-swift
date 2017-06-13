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
    
    func loadAttributesIntoObject(object: XMLNode, properties: [String: Any]) {
        for property in properties {
            assignValueFromAttribute(object: object, attribute: property.key, value: property.value as! String)
        }
        
        object.loadCustomProperties(properties)
    }
    
    func assignValueFromAttribute(object: XMLNode, attribute: String, value: String) {
        let propertyName = attribute.camelCased
        
        if object.customProperties() != nil && (object.customProperties()?.contains(propertyName))! {
            object.performCustomProperty(propertyName: propertyName, value: value)
            return
        }
        
        if !object.properties().contains(propertyName) {
            return
        }
        
        let property = object.value(forKey: propertyName)
        
        switch property {
        case is String:
            object.setValue(value, forKey: propertyName)
        case is CGFloat:
            guard let newValue = NumberFormatter().number(from: value) else { return }
            object.setValue(newValue, forKey: propertyName)
        case is Bool:
            let newValue = value == "true" ? true : false
            object.setValue(newValue, forKey: propertyName)
        case is UIColor:
            let newValue = value.getRGBAColor()
            object.setValue(newValue, forKey: propertyName)
        case is UIImage:
            guard let image = UIImage(named: value) else {
                return
            }
            object.setValue(image, forKey: propertyName)
        case is TractMainStyle.BackgroundImageAlign:
            setupImageAlign(object: object, propertyName: propertyName, kind: value)
        case is [TractMainStyle.BackgroundImageAlign]:
            setupImageAligns(object: object, propertyName: propertyName, kind: value)
        default:
            object.performCustomProperty(propertyName: propertyName, value: value)
        }
        
        _ = 1
    }
    
    func setupImageAlign(object: XMLNode, propertyName: String, kind: String) {
        object.setValue(TractMainStyle.getImageAlignKind(string: kind), forKey: propertyName)
    }
    
    func setupImageAligns(object: XMLNode, propertyName: String, kind: String) {
        var items: [TractMainStyle.BackgroundImageAlign] = []
        
        for value in kind.components(separatedBy: " ") {
            items.append(TractMainStyle.getImageAlignKind(string: value))
        }
        
        object.setValue(items, forKey: propertyName)
    }
    
    func setupImageScaleType(object: XMLNode, propertyName: String, kind: String) {
        object.setValue(TractMainStyle.getImageScaleType(string: kind), forKey: propertyName)
    }

}
