//
//  ContentParagraphNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentParagraphNode: MobileContentXmlNode, MobileContentRenderableNode {
    
    let fallback: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        fallback = attributes["fallback"]?.text
        
        super.init(xmlElement: xmlElement)
    }
}

extension ContentParagraphNode {
    
    var isFallback: Bool {
        return fallback == "true"
    }
}
