//
//  ContentImageNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentImageNode: MobileContentXmlNode {
        
    let events: [String]
    let resource: String?
    let restrictTo: String?
    
    required init(xmlElement: XMLElement, position: Int) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        events = attributes["events"]?.text.components(separatedBy: " ") ?? []
        resource = attributes["resource"]?.text
        restrictTo = attributes["restrictTo"]?.text
        
        super.init(xmlElement: xmlElement, position: position)
    }
}

// MARK: - MobileContentRenderableNode

extension ContentImageNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
