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
    static func buildAnalyticsEvents(data: XMLIndexer) -> [[String: String]] {
        
        var analyticsArray = [[String: String]]()
        
        // MARK: - This parses out system info and action string !!!
        for event in data.children {
            var analyticsEvents: [String: String] = [:]
//            if !xmlManager.parser.nodeIsEvent(node: node) { continue }
            guard let eventElement = event.element else { continue }
            let nodeHasAttributes = (eventElement.allAttributes.count > 0)
            
            if nodeHasAttributes {
                for (_, dictionary) in (eventElement.allAttributes.enumerated()) {
                    analyticsEvents[dictionary.key] = dictionary.value.text
                }
            }
            
            // MARK: - This parses out attribute keys and values !!!
            for attribute in event.children {
                guard let attributeElement = attribute.element else { continue }
                let childrenHasAttributes = (attributeElement.allAttributes.count > 0)
                
                if childrenHasAttributes {
                    var attributeStrings = [String]()
                    for attribute in attributeElement.allAttributes {
                        attributeStrings.append(attribute.value.text)
                    }
                    guard attributeStrings.count == 2 else { continue }
                    analyticsEvents[attributeStrings[0]] = attributeStrings[1]
                }
            }
            guard analyticsEvents.count > 0 else { continue }
            analyticsArray.append(analyticsEvents)
        }
        
        return analyticsArray
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
