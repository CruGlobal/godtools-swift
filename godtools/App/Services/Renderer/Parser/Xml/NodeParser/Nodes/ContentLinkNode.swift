//
//  ContentLinkNode.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentLinkNode: MobileContentXmlNode, ContentLinkModelType {
        
    private var textNode: ContentTextNode?
    private var analyticsEventsNode: AnalyticsEventsNode?
    
    let events: [MultiplatformEventId]
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        //let eventNames: [String] = attributes["events"]?.text.components(separatedBy: " ") ?? []
        events = Array()
        
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
    
    var text: String? {
        return textNode?.text
    }
    
    func getTextColor() -> MobileContentColor? {
        return textNode?.getTextColor()
    }
    
    func getAnalyticsEvents() -> [AnalyticsEventModelType] {
        return analyticsEventsNode?.analyticsEventNodes ?? []
    }
}
