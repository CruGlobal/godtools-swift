//
//  TractEventHelper.swift
//  godtools
//
//  Created by Ryan Carlson on 6/14/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class TractEventHelper {
    static func buildAnalyticsEvents(data: XMLIndexer) -> [String: String] {
        var analyticsEvents: [String: String] = [:]
        let xmlManager = XMLManager()
        
        // MARK: - This parses out system info and action string !!!
        for node in data.children {
            
            if !xmlManager.parser.nodeIsEvent(node: node) { continue }
            guard let nodeElement = node.element else { continue }
            let nodeHasAttributes = !nodeElement.allAttributes.isEmpty
            
            if nodeHasAttributes {
                for (_, dictionary) in (nodeElement.allAttributes.enumerated()) {
                    analyticsEvents[dictionary.key] = dictionary.value.text
                }
            }
            
            // MARK: - This parses out analytic key and value !!!
            for child in node.children {
                guard let childElement = child.element else { continue }
                let childrenHasAttributes = !childElement.allAttributes.isEmpty
                
                if childrenHasAttributes {
                    for (_, dictionary) in (childElement.allAttributes.enumerated()) {
                        analyticsEvents[dictionary.key] = dictionary.value.text
                    }
                }
            }
        }
        
        let adjustedAnalyticsEvents = adjustVerboseDictionary(from: analyticsEvents)
        return adjustedAnalyticsEvents
    }
    
    private static func adjustVerboseDictionary(from dictionary: [String: String]) -> [String: String] {
        var copy = dictionary
        if let copyKey = copy["key"], let copyValue = copy["value"] {
            copy.removeValue(forKey: "key")
            copy.removeValue(forKey: "value")
            copy[copyKey] = copyValue
        }
        return copy
    }
}
