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
        
    let events: [MultiplatformEventId]
    let resource: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        //let eventNames: [String] = attributes["events"]?.text.components(separatedBy: " ") ?? []
        events = Array()
        resource = attributes["resource"]?.text
        
        super.init(xmlElement: xmlElement)
    }
}
