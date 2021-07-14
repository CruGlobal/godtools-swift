//
//  AnalyticsAttributeNode.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class AnalyticsAttributeNode: MobileContentXmlNode, AnalyticsAttributeModelType {
        
    let key: String?
    let value: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        key = attributes["key"]?.text
        value = attributes["value"]?.text
        
        super.init(xmlElement: xmlElement)
    }
}
