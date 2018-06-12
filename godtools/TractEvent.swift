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
    
    // MARK: - Helpers
    
    func eventProperties() -> TractEventProperties {
        return self.properties as! TractEventProperties
    }
    
}
