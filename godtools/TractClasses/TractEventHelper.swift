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
    static func buildAnalyticsEvents(data: XMLIndexer) -> [TractAnalyticEvent] {
        
        var tractAnalyticEvents = [TractAnalyticEvent]()
        
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
                    for (_, dictionary) in (attributeElement.allAttributes.enumerated()) {
                        analyticsEvents[dictionary.key] = dictionary.value.text
                        analyticsEvents = assignKeyAndValue(from: analyticsEvents)
                    }
                }
            }
            guard analyticsEvents.count > 0 else { continue }
            let tractEvent = TractAnalyticEvent(dictionary: analyticsEvents)
            tractAnalyticEvents.append(tractEvent)
        }
        
        return tractAnalyticEvents
    }
    
    private static func assignKeyAndValue(from dictionary: [String: String]) -> [String: String] {
        var copy = dictionary
        if let copyKey = copy["key"], let copyValue = copy["value"] {
            copy.removeValue(forKey: "key")
            copy.removeValue(forKey: "value")
            copy[copyKey] = copyValue
        }
        return copy
    }
    
}
