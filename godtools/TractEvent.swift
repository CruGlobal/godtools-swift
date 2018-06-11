//
//  TractEvent.swift
//  godtools
//
//  Created by Greg Weiss on 5/7/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import UIKit
import SWXMLHash

class TractEvent: BaseTractElement {
    
   // var analyticsEvents: [String: String] = [:]
    
    override func propertiesKind() -> TractProperties.Type {
        return TractEventProperties.self
    }
    
    override func setupView(properties: [String: Any]) {
        super.setupView(properties: properties)
        TractBindings.addBindings(self)
    }
    
    override func attachAnalyticsData(data: XMLIndexer) -> [String : String] {
        var analyticsEvents: [String: String] = [:]
      
        var nodeMayHaveAttributes = false
        var childrenMayHaveAttributes = false
        
        // MARK: - This parses out system info and action string !!!
        for node in data.children {
            if self.xmlManager.parser.nodeIsEvent(node: node) {
                if let nodeAttributesIsEmpty = node.element?.allAttributes.isEmpty {
                    nodeMayHaveAttributes = !nodeAttributesIsEmpty
                }
                if nodeMayHaveAttributes {
                    for (num, dictionary) in (node.element!.allAttributes.enumerated()) {
                        let _ = num
                        analyticsEvents[dictionary.key] = dictionary.value.text
                    }
                }
                
                // MARK: - This parses out analytic key and value !!!
                for child in node.children {
                    if let childAttributesIsEmpty = child.element?.allAttributes.isEmpty {
                        childrenMayHaveAttributes = !childAttributesIsEmpty
                    }
                    if childrenMayHaveAttributes {
                        analyticsEvents = processNode(child, analyticsDictionary: analyticsEvents)
                    }
                }
            }
        }
        if analyticsEvents.isEmpty {
            return [:]
        } else {
            return analyticsEvents
        }
    }
    
    static func attachAnalyticsEvents(data: XMLIndexer) -> [String: String] {
        var analyticsEvents: [String: String] = [:]
        let xmlManager = XMLManager()
        
        var nodeMayHaveAttributes = false
        var childrenMayHaveAttributes = false
        
        // MARK: - This parses out system info and action string !!!
        for node in data.children {
            if xmlManager.parser.nodeIsEvent(node: node) {
                if let nodeAttributesIsEmpty = node.element?.allAttributes.isEmpty {
                    nodeMayHaveAttributes = !nodeAttributesIsEmpty
                }
                if nodeMayHaveAttributes {
                    for (num, dictionary) in (node.element!.allAttributes.enumerated()) {
                        let _ = num
                        analyticsEvents[dictionary.key] = dictionary.value.text
                    }
                }
                
                // MARK: - This parses out analytic key and value !!!
                for child in node.children {
                    if let childAttributesIsEmpty = child.element?.allAttributes.isEmpty {
                        childrenMayHaveAttributes = !childAttributesIsEmpty
                    }
                    if childrenMayHaveAttributes {
                        for (num, dictionary) in (child.element!.allAttributes.enumerated()) {
                            let _ = num
                            analyticsEvents[dictionary.key] = dictionary.value.text
                        }
                    }
                }
            }
        }
        if analyticsEvents.isEmpty {
            return [:]
        } else {
            print("\(analyticsEvents)")
            return analyticsEvents
        }
    }
    
    // MARK: - Bindings
    
    override func elementListeners() -> [String]? {
        return nil
    }
    
    override func receiveMessage() {
        
    }
    
    // MARK: - Helpers
    
    func eventProperties() -> TractEventProperties {
        return self.properties as! TractEventProperties
    }
    
    
    func processNode(_ node: XMLIndexer, analyticsDictionary: [String: String]) -> [String: String] {
        var newDictionary: [String: String] = analyticsDictionary
        guard let key = node.element?.allAttributes["key"] else { return newDictionary }
        guard let value = node.element?.allAttributes["value"] else { return newDictionary }
        let keyString = "\(key)"
        let valueString = "\(value)"
      //  newDictionary[removeUnwantedCharacters(from: keyString)] = removeUnwantedCharacters(from: valueString)
        return newDictionary
    }
    
   static func removeUnwantedCharacters(from xmlText: String) -> String {
        var newXMLString = ""
        let containsEquals = xmlText.contains("=")
        let containsBackslashes = xmlText.contains("\\")
        let containsQuotes = xmlText.contains("\"")
        if containsEquals {
            let components = xmlText.components(separatedBy: "=")
            guard components.count > 1 else {
                return newXMLString
            }
            newXMLString = components[1]
        }
        if containsBackslashes {
            newXMLString = newXMLString.replacingOccurrences(of: "\\", with: "")
        }
        if containsQuotes {
            newXMLString = newXMLString.replacingOccurrences(of: "\"", with: "")
        }
        return newXMLString
    }
    
}
