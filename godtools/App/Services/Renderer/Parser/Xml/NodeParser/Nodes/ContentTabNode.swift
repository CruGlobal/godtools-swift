//
//  ContentTabNode.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentTabNode: MobileContentXmlNode, ContentTabModelType {
    
    private var analyticsEventsNode: AnalyticsEventsNode?
    
    let listeners: [String]
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        listeners = attributes["listeners"]?.text.components(separatedBy: " ") ?? []
        
        super.init(xmlElement: xmlElement)
    }
    
    private var contentLabelNode: ContentLabelNode? {
        return children.first as? ContentLabelNode
    }
    
    override func addChild(childNode: MobileContentXmlNode) {
        
        if let analyticsEventsNode = childNode as? AnalyticsEventsNode {
            self.analyticsEventsNode = analyticsEventsNode
        }
        
        super.addChild(childNode: childNode)
    }
    
    var text: String? {
        return contentLabelNode?.textNode?.text
    }
    
    func getAnalyticsEvents() -> [AnalyticsEventModelType] {
        return analyticsEventsNode?.analyticsEventNodes ?? []
    }
}
