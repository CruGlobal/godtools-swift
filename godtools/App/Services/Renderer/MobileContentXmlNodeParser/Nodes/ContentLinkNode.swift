//
//  ContentLinkNode.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentLinkNode: MobileContentXmlNode {
        
    private(set) var textNode: ContentTextNode?
    private(set) var analyticsEventsNode: AnalyticsEventsNode?
    
    let events: [String]
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        events = attributes["events"]?.text.components(separatedBy: " ") ?? []
        
        super.init(xmlElement: xmlElement)
    }
    
    override func addChild(childNode: MobileContentXmlNode) {
        
        if let textNode = childNode as? ContentTextNode {
            self.textNode = textNode
        }
        else if let analyticsEventsNode = childNode as? AnalyticsEventsNode {
            self.analyticsEventsNode = analyticsEventsNode
        }
        
        super.addChild(childNode: childNode)
    }
}

// MARK: - MobileContentRenderableNode

extension ContentLinkNode: MobileContentRenderableNode {
    var contentIsRenderable: Bool {
        return true
    }
}
