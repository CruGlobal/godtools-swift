//
//  ContentInputNode.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentInputNode: MobileContentXmlNode {
        
    let name: String?
    let type: String?
    let value: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        name = attributes["name"]?.text
        type = attributes["type"]?.text
        value = attributes["value"]?.text
        
        super.init(xmlElement: xmlElement)
    }
}
