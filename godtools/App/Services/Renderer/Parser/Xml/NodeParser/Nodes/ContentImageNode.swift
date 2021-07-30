//
//  ContentImageNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentImageNode: MobileContentXmlNode, ContentImageModelType {
        
    let events: [String]
    let resource: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        events = attributes["events"]?.text.components(separatedBy: " ") ?? []
        resource = attributes["resource"]?.text
        
        super.init(xmlElement: xmlElement)
    }
}
