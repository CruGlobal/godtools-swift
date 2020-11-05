//
//  ContentButtonNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentButtonNode: MobileContentXmlNode {
    
    let events: String?
    let type: String?
    let url: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        events = attributes["events"]?.text
        type = attributes["type"]?.text
        url = attributes["url"]?.text
        
        super.init(xmlElement: xmlElement)
    }
    
    var textNode: ContentTextNode? {
        return children.first as? ContentTextNode
    }
}
