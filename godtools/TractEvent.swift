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
    
    override func propertiesKind() -> TractProperties.Type {
        return TractEventProperties.self
    }
    
    override func setupView(properties: [String: Any]) {
        super.setupView(properties: properties)
        TractBindings.addBindings(self)
    }
    
    static func buildAnalyticsEvents(data: XMLIndexer) -> [String: String] {
        var analyticsEvents: [String: String] = [:]
        let xmlManager = XMLManager()
        
        var nodeMayHaveAttributes = false
        var childrenMayHaveAttributes = false
        
        // MARK: - This parses out system info and action string !!!
        for node in data.children {
            
            if !xmlManager.parser.nodeIsEvent(node: node) { continue }
            guard let nodeElement = node.element else { continue }
            nodeMayHaveAttributes = !nodeElement.allAttributes.isEmpty
            
            if nodeMayHaveAttributes {
                for (_, dictionary) in (nodeElement.allAttributes.enumerated()) {
                    analyticsEvents[dictionary.key] = dictionary.value.text
                }
            }
            
            // MARK: - This parses out analytic key and value !!!
            for child in node.children {
                guard let childElement = child.element else { continue }
                childrenMayHaveAttributes = !childElement.allAttributes.isEmpty
                
                if childrenMayHaveAttributes {
                    for (_, dictionary) in (childElement.allAttributes.enumerated()) {
                        analyticsEvents[dictionary.key] = dictionary.value.text
                    }
                }
            }
        }
        
        let adjustedAnalyticsEvents = adjustVerboseDictionary(from: analyticsEvents)
        return adjustedAnalyticsEvents
    }
    
    // MARK: - Bindings
    
    override func elementListeners() -> [String]? {
        return nil
    }
    
    // MARK: - Helpers
    
    static func adjustVerboseDictionary(from dictionary: [String: String]) -> [String: String] {
        var copy = dictionary
        if let copyKey = copy["key"], let copyValue = copy["value"] {
            copy.removeValue(forKey: "key")
            copy.removeValue(forKey: "value")
            copy[copyKey] = copyValue
        }
        return copy
    }
    
    func eventProperties() -> TractEventProperties {
        return self.properties as! TractEventProperties
    }
    
}
