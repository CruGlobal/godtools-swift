//
//  AnalyticsEventNode.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class AnalyticsEventNode: MobileContentXmlNode, AnalyticsEventModelType {
        
    private let triggerString: String?
    
    let action: String?
    let delay: String?
    let systems: [String]
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        action = attributes["action"]?.text
        delay = attributes["delay"]?.text
        systems = attributes["system"]?.text.components(separatedBy: " ") ?? []
        triggerString = attributes["trigger"]?.text
        
        super.init(xmlElement: xmlElement)
    }
    
    var triggerName: String? {
        return triggerString
    }
    
    func getAttributes() -> [String: String] {
        
        var attributes: [String: String] = Dictionary()
        
        for childNode in children {
            if let attributeNode = childNode as? AnalyticsAttributeNode, let key = attributeNode.key, let value = attributeNode.value, !key.isEmpty, !value.isEmpty {
                attributes[key] = value
            }
        }
        
        return attributes
    }
}
