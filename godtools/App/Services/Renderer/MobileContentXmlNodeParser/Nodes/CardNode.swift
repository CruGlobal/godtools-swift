//
//  CardNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class CardNode: MobileContentXmlNode, BackgroundImageNodeType, MobileContentRenderableNode {
        
    private(set) var labelNode: LabelNode?
    private(set) var analyticsEventsNode: AnalyticsEventsNode?
    
    let backgroundImage: String?
    let backgroundImageAlign: String
    let backgroundImageScaleType: String
    let dismissListeners: [String]
    let hidden: String?
    let listeners: [String]
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        backgroundImage = attributes["background-image"]?.text
        backgroundImageAlign = attributes["background-image-align"]?.text ?? "center"
        backgroundImageScaleType = attributes["background-image-scale-type"]?.text ?? "fill-x"
        dismissListeners = attributes["dismiss-listeners"]?.text.components(separatedBy: " ") ?? []
        hidden = attributes["hidden"]?.text
        listeners = attributes["listeners"]?.text.components(separatedBy: " ") ?? []
        
        super.init(xmlElement: xmlElement)
    }
    
    override func addChild(childNode: MobileContentXmlNode) {
        
        if let labelNode = childNode as? LabelNode {
            self.labelNode = labelNode
        }
        else if let analyticsEventsNode = childNode as? AnalyticsEventsNode {
            self.analyticsEventsNode = analyticsEventsNode
        }
        
        super.addChild(childNode: childNode)
    }
}
