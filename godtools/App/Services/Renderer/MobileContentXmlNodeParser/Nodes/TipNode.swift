//
//  TipNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class TipNode: MobileContentXmlNode, MobileContentRenderableNode {
        
    let tipType: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        if let tipTypeAttribute = attributes["type"] {
            tipType = tipTypeAttribute.text
        }
        else {
            tipType = nil
        }
        
        super.init(xmlElement: xmlElement)
    }
    
    var pages: PagesNode? {
        return children.first as? PagesNode
    }
}
