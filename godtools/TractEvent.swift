//
//  TractEvent.swift
//  godtools
//
//  Created by Greg Weiss on 5/7/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import UIKit
import SWXMLHash

protocol ButtonActionAnalyticsProtocol: class {
    func handleTrackedAction()
}

class TractEvent: BaseTractElement {
    
    var analyticsEvents = [String: String]()
    
    override func propertiesKind() -> TractProperties.Type {
        return TractEventProperties.self
    }
    
    override func setupView(properties: [String: Any]) {
        super.setupView(properties: properties)
        TractBindings.addBindings(self)
    }
    
    override func attachAnalyticsData(data: XMLIndexer) -> [String : String]? {
      
        var nodeMayHaveAttributes = false
        var childrenMayHaveAttributes = false
        // let contentElements = self.xmlManager.getContentElements(data)
        // var elements = [XMLIndexer]()
        
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
                        processNode(child)
                    }
                }
            }
        }
        return analyticsEvents

       // print("analytics EVENTS: \(analyticsEvents)\n")
        
    }
    
    public static func getAnalyticsInfo(completion: @escaping ([String: String]) -> ()) {
//        let dict = analyticsEvents
//        completion(dictionary)
       
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
    
    func processNode(_ node: XMLIndexer) {
        guard let key = node.element?.allAttributes["key"] else { return }
        guard let value = node.element?.allAttributes["value"] else { return }
        let keyString = "\(key)"
        let valueString = "\(value)"
        analyticsEvents[removeUnwantedCharacters(from: keyString)] = removeUnwantedCharacters(from: valueString)
    }
    
    func removeUnwantedCharacters(from xmlText: String) -> String {
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
