//
//  ContentTabNode.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentTabNode: MobileContentXmlNode {
    
    private(set) var analyticsEventsNode: AnalyticsEventsNode?
    
    required init(xmlElement: XMLElement) {
    
        super.init(xmlElement: xmlElement)
    }
    
    var contentLabelNode: ContentLabelNode? {
        return children.first as? ContentLabelNode
    }
    
    override func addChild(childNode: MobileContentXmlNode) {
        
        if let analyticsEventsNode = childNode as? AnalyticsEventsNode {
            self.analyticsEventsNode = analyticsEventsNode
        }
        
        super.addChild(childNode: childNode)
    }
}
