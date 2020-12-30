//
//  AnalyticsEventNode.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class AnalyticsEventNode: MobileContentXmlNode {
        
    let action: String?
    let delay: String?
    let systems: [String]
    let trigger: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        action = attributes["action"]?.text
        delay = attributes["delay"]?.text
        systems = attributes["system"]?.text.components(separatedBy: " ") ?? []
        trigger = attributes["trigger"]?.text
        
        super.init(xmlElement: xmlElement)
    }
}
